import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/model/impaktfull_appstore_build.dart';

/// The five routes of the appstore CI surface (`/api/ci/*`).
///
/// That surface is a stability promise: it is called from pipelines nobody at
/// impaktfull can redeploy, so it changes additively only. This client is
/// written against it directly rather than through a generated layer, so the
/// four calls a release makes are readable in one file.
///
/// Nothing here logs the upload key or a presigned URL. The key is a
/// credential, and a presigned URL is a credential too: it carries a signature
/// that grants a write to the artifact for as long as it lives.
class ImpaktfullAppstoreApi {
  final Uri baseUrl;
  final Secret uploadKey;
  final http.Client _client;

  ImpaktfullAppstoreApi({
    required this.baseUrl,
    required this.uploadKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  void dispose() => _client.close();

  /// `GET /api/ci/app`.
  ///
  /// Called FIRST, always. It validates the key and returns the environments
  /// the key may write to, so `staging` typed as `stagng` is reported in a
  /// second rather than after a gigabyte has been transferred.
  Future<ImpaktfullAppstoreApp> getApp() async {
    final response = await _client.get(
      baseUrl.resolve('/api/ci/app'),
      headers: _headers(),
    );
    return ImpaktfullAppstoreApp.fromJson(_decode(response, 'read the app'));
  }

  /// `POST /api/ci/builds`.
  ///
  /// Returns the build and, unless the server already had these exact bytes,
  /// the presigned URL to PUT them to.
  Future<ImpaktfullAppstoreUploadTicket> initiateUpload({
    required String environmentName,
    required String fileName,
    required int sizeBytes,
    required String sha256,
    String? releaseNotes,
    Map<String, dynamic>? ci,
  }) async {
    final response = await _client.post(
      baseUrl.resolve('/api/ci/builds'),
      headers: _headers(json: true),
      body: jsonEncode({
        'environmentName': environmentName,
        'fileName': fileName,
        'sizeBytes': sizeBytes,
        'sha256': sha256,
        if (releaseNotes != null) 'releaseNotes': releaseNotes,
        if (ci != null && ci.isNotEmpty) 'ci': ci,
      }),
    );
    final body = _decode(response, 'start the upload');
    return ImpaktfullAppstoreUploadTicket.fromJson(body);
  }

  /// PUTs the artifact to the presigned URL, STREAMED.
  ///
  /// Streamed from disk rather than read into memory: a Flutter IPA with assets
  /// reaches several hundred megabytes and a game reaches a gigabyte, and a CI
  /// runner holding that in the heap alongside the Dart VM is an out-of-memory
  /// kill with no useful message.
  ///
  /// The bytes go STRAIGHT TO STORAGE and never through the appstore server.
  Future<void> uploadArtifact({
    required Uri url,
    required Map<String, String> headers,
    required File file,
    required int sizeBytes,
    void Function(int sent, int total)? onProgress,
  }) async {
    final request = http.StreamedRequest('PUT', url);
    // EXACTLY the headers the server gave, and nothing else. They are part of
    // what the signature covers, so an extra or altered one turns a valid URL
    // into a refusal from storage that mentions a string nobody can see.
    request.headers.addAll(headers);
    request.contentLength = sizeBytes;

    var sent = 0;
    unawaited(
      file.openRead().forEach((chunk) {
        request.sink.add(chunk);
        sent += chunk.length;
        onProgress?.call(sent, sizeBytes);
      }).then(
        (_) => request.sink.close(),
        onError: (Object error, StackTrace trace) {
          request.sink.addError(error, trace);
          return request.sink.close();
        },
      ),
    );

    final response = await _client.send(request);
    // DRAINED, not read. The body of a failed storage response is XML written
    // for a machine, and on a signature failure it quotes the string that was
    // signed. The status is the part anybody can act on.
    await response.stream.drain<void>();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ImpaktfullCliError(
        'Failed to upload the artifact to storage (${response.statusCode}). '
        'The upload URL may have expired; run the upload again.',
      );
    }
  }

  /// `POST /api/ci/builds/:id/complete`. Hands the build to the inspector.
  Future<void> completeUpload(String buildId) async {
    final response = await _client.post(
      baseUrl.resolve('/api/ci/builds/$buildId/complete'),
      headers: _headers(json: true),
    );
    _decode(response, 'complete the upload');
  }

  /// `GET /api/ci/builds/:id`. What the CLI polls while the server inspects.
  Future<ImpaktfullAppstoreBuild> getBuild(String buildId) async {
    final response = await _client.get(
      baseUrl.resolve('/api/ci/builds/$buildId'),
      headers: _headers(),
    );
    final body = _decode(response, 'read the build');
    return ImpaktfullAppstoreBuild.fromJson(
      body['build'] as Map<String, dynamic>,
      url: body['url'] as String?,
    );
  }

  /// `DELETE /api/ci/builds/:id`. Cancels an upload that never finished.
  ///
  /// Best effort by design: this runs while something else has already gone
  /// wrong, and an error here would replace the real failure with this one.
  Future<void> cancelBuild(String buildId) async {
    try {
      await _client.delete(
        baseUrl.resolve('/api/ci/builds/$buildId'),
        headers: _headers(json: true),
      );
    } catch (error) {
      ImpaktfullCliLogger.verbose('Could not cancel the build: $error');
    }
  }

  /// SHA-256 of a file, computed by STREAMING it.
  ///
  /// The server dedupes on this hash and verifies it against what actually
  /// landed in storage, so bytes that do not match what was declared never
  /// become an installable build. Streaming for the same reason the upload
  /// streams: peak memory is one chunk rather than the whole artifact.
  static Future<String> hashFile(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  Map<String, String> _headers({bool json = false}) => {
        'Authorization': 'Bearer ${uploadKey.value}',
        'Accept': 'application/json',
        if (json) 'Content-Type': 'application/json',
      };

  /// Decodes a response, turning the server's error envelope into a message.
  ///
  /// The server sends `{"error":{"code":...,"message":...}}` and the message is
  /// written to be read by whoever is looking at the pipeline log. The CODE is
  /// appended because it is what somebody would search for or quote.
  Map<String, dynamic> _decode(http.Response response, String what) {
    Map<String, dynamic>? body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      } on FormatException {
        body = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body ?? <String, dynamic>{};
    }

    final error = body?['error'];
    if (error is Map<String, dynamic>) {
      throw ImpaktfullCliError(
        'Failed to $what: ${error['message']} (${error['code']})',
      );
    }
    if (response.statusCode == 401) {
      throw ImpaktfullCliError(
        'Failed to $what: the upload key was refused. It may have been revoked '
        'or it may belong to another instance.',
      );
    }
    throw ImpaktfullCliError(
      'Failed to $what: the server answered ${response.statusCode}.',
    );
  }
}

/// What `POST /api/ci/builds` returns.
class ImpaktfullAppstoreUploadTicket {
  final ImpaktfullAppstoreBuild build;

  /// Absent when the server already had these bytes, and absent when the build
  /// has already moved on to the inspector. Both mean there is nothing to
  /// transfer.
  final ImpaktfullAppstoreUpload? upload;

  /// The server recognised this artifact: same bytes, same environment. The
  /// existing build is returned rather than a second copy being made.
  final bool isDuplicate;

  const ImpaktfullAppstoreUploadTicket({
    required this.build,
    this.upload,
    this.isDuplicate = false,
  });

  factory ImpaktfullAppstoreUploadTicket.fromJson(Map<String, dynamic> json) {
    final upload = json['upload'];
    return ImpaktfullAppstoreUploadTicket(
      build: ImpaktfullAppstoreBuild.fromJson(
        json['build'] as Map<String, dynamic>,
      ),
      upload: upload is Map<String, dynamic>
          ? ImpaktfullAppstoreUpload.fromJson(upload)
          : null,
      isDuplicate: json['duplicate'] == true,
    );
  }
}

/// A presigned PUT: where to send the bytes, and with which headers.
class ImpaktfullAppstoreUpload {
  final Uri url;
  final Map<String, String> headers;
  final DateTime? expiresAt;

  const ImpaktfullAppstoreUpload({
    required this.url,
    required this.headers,
    this.expiresAt,
  });

  factory ImpaktfullAppstoreUpload.fromJson(Map<String, dynamic> json) {
    final headers = (json['headers'] as Map<String, dynamic>? ?? {})
        .map((key, value) => MapEntry(key, value.toString()));
    return ImpaktfullAppstoreUpload(
      url: Uri.parse(json['url'] as String),
      headers: headers,
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? ''),
    );
  }
}
