import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:http/http.dart' as http;
import 'package:impaktfull_cli/src/plugin/impaktfull_plugin.dart';
import 'package:impaktfull_cli/src/util/extensions/list_extensions.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:io';

const _appCenterApiBaseUrl = 'https://api.appcenter.ms/v0.1';
const _appCenterFilesBaseUrl = 'https://file.appcenter.ms';
String _tempDirectoryPath =
    join("build", 'impaktfull_cli', 'appcenter', 'upload');
const _extensionMimeTypeMapper = {
  'apk': 'application/vnd.android.package-archive',
  'ipa': 'application/octet-stream',
};

/// Login based on these 2 resources:
/// - https://medium.com/@tranhuuphuc20051995/uploading-apk-files-to-appcenter-using-bash-script-bde8a796145d
/// - https://gist.github.com/ouchadam/c74fa26c639a50d68bc35ee5749f868c
class AppCenterPlugin extends ImpaktfullPlugin {
  const AppCenterPlugin();

  Future<void> uploadToAppCenter({
    required String appName,
    required File file,
    String? ownerName,
    Secret? apiToken,
    List<String> distributionGroups = const ['Collaborators'],
    bool notifyListeners = true,
  }) async {
    final ownerNameValue =
        ownerName ?? ImpaktfullCliEnvironmentVariables.getAppCenterOwnerName();
    final apiTokenSecret =
        apiToken ?? ImpaktfullCliEnvironmentVariables.getAppCenterToken();

    // =========CREATE NEW RELEASE==========
    final createNewReleaseUploadResponse = await _createNewRelease(
      appName: appName,
      ownerName: ownerNameValue,
      apiToken: apiTokenSecret,
    );
    final id = createNewReleaseUploadResponse['id'] as String;
    final packageAssetId =
        createNewReleaseUploadResponse['package_asset_id'] as String;
    final urlEncodedToken =
        createNewReleaseUploadResponse['url_encoded_token'] as String;

    final fileSizeBytes = await file.length();
    final appType = _getAppTypeFor(file);
    ImpaktfullCliLogger.verbose('Detected: $appType meme type fo ${file.path}');

    // =========UPLOAD METADATA TO GET CHUNK SIZE==========
    final chunkSize = await _uploadMetadata(
      packageAssetId: packageAssetId,
      file: file,
      fileSize: fileSizeBytes,
      urlEncodedToken: urlEncodedToken,
      appType: appType,
      apiToken: apiTokenSecret,
    );

    // =========CREATE FOLDER TEMP/SPLIT TO STORAGE LIST CHUNK FILE AFTER SPLIT==========
    final tempDirectory = Directory(join(_tempDirectoryPath, 'split'));
    if (!tempDirectory.existsSync()) {
      tempDirectory.createSync(recursive: true);
    }

    // =========SPLIT FILE==========
    await _splitFile(
      inputFile: file,
      outputDirectory: tempDirectory,
      chunkSize: chunkSize,
    );

    // =========UPLOAD CHUNK==========
    await _uploadChunks(
      packageAssetId: packageAssetId,
      urlEncodedToken: urlEncodedToken,
      tempDirectory: tempDirectory,
      appType: appType,
    );

    // =========FINISHED==========
    await _finishUpload(
      packageAssetId: packageAssetId,
      urlEncodedToken: urlEncodedToken,
      apiToken: apiTokenSecret,
    );

    // =========COMMIT==========
    await _commitRelease(
      id: id,
      appName: appName,
      ownerName: ownerNameValue,
      apiToken: apiTokenSecret,
    );

    // =========POLL RESULT==========
    final releaseId = await _validateRelease(
      id: id,
      appName: appName,
      ownerName: ownerNameValue,
      apiToken: apiTokenSecret,
    );

    // =========DISTRIBUTE==========
    final distributionUrl = await _distributeRelease(
      appName: appName,
      ownerName: ownerNameValue,
      releaseId: releaseId,
      distributionGroups: distributionGroups,
      notifyListeners: notifyListeners,
      apiToken: apiTokenSecret,
    );
    ImpaktfullCliLogger.logSeperator();
    ImpaktfullCliLogger.log('Release $releaseId is ready!!! 🎉🎉🎉');
    ImpaktfullCliLogger.log(distributionUrl);
    ImpaktfullCliLogger.logSeperator();
    await cleanup();
  }

  Future<Map<String, dynamic>> _createNewRelease({
    required String ownerName,
    required String appName,
    required Secret apiToken,
  }) async {
    final response = await http.post(
      Uri.parse(
          "$_appCenterApiBaseUrl/apps/$ownerName/$appName/uploads/releases"),
      headers: _getHeaders(apiToken),
    );
    if (response.statusCode != HttpStatus.created) {
      ImpaktfullCliLogger.verbose(response.body);
      throw ImpaktfullCliError('Failed to create release on AppCenter');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<int> _uploadMetadata({
    required String packageAssetId,
    required File file,
    required int fileSize,
    required String urlEncodedToken,
    required String appType,
    required Secret apiToken,
  }) async {
    final fileName = basename(file.path);
    final metaDataUrl =
        "$_appCenterFilesBaseUrl/upload/set_metadata/$packageAssetId?file_name=$fileName&file_size=$fileSize&token=$urlEncodedToken&content_type=$appType";
    final response = await http.post(
      Uri.parse(metaDataUrl),
      headers: _getHeaders(apiToken),
    );
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode != HttpStatus.ok) {
      ImpaktfullCliLogger.verbose(response.body);
      throw ImpaktfullCliError('Failed to upload metadata to AppCenter');
    }
    return data['chunk_size'] as int;
  }

  Future<void> _splitFile({
    required File inputFile,
    required Directory outputDirectory,
    required int chunkSize,
  }) async {
    if (outputDirectory.existsSync()) {
      outputDirectory.deleteSync(recursive: true);
    }
    outputDirectory.createSync(recursive: true);

    final chunks = (await inputFile.readAsBytes()).buffer.asUint8List();

    var chunksUsed = 0;
    var chunksIndex = 0;

    while (chunksUsed < chunks.length) {
      chunksIndex++;
      final newChunksUsed = chunksUsed + chunkSize > chunks.length
          ? chunks.length
          : chunksUsed + chunkSize;
      final chunk = chunks.sublist(chunksUsed, newChunksUsed);
      final chunkFile =
          File(join(outputDirectory.path, 'chunk_$chunksIndex.apk'));
      await chunkFile.writeAsBytes(chunk);
      chunksUsed = newChunksUsed;
    }
    ImpaktfullCliLogger.debug('Split the file into $chunksIndex chunks');
  }

  Future<void> _uploadChunks({
    required String packageAssetId,
    required String urlEncodedToken,
    required Directory tempDirectory,
    required String appType,
  }) async {
    final tempFiles = tempDirectory.listSync().whereType<File>().toList()
      ..sortBy((file) {
        final fileName = basenameWithoutExtension(file.path);
        return int.parse(fileName.split('_').last);
      });
    for (final file in tempFiles) {
      final fileName = basenameWithoutExtension(file.path);
      final blockNumber = int.parse(fileName.split('_').last);
      final contentLength = file.lengthSync();
      final uploadChunkurl =
          "$_appCenterFilesBaseUrl/upload/upload_chunk/$packageAssetId?token=$urlEncodedToken&block_number=$blockNumber";
      final chunkProgress = '$blockNumber/${tempFiles.length}';

      ImpaktfullCliLogger.log('Uploading chunks: $chunkProgress');

      final response = await http.post(
        Uri.parse(uploadChunkurl),
        headers: {
          'Content-Length': '$contentLength',
          'Content-Type': appType,
        },
        body: file.readAsBytesSync(),
      );

      if (response.statusCode != HttpStatus.ok) {
        ImpaktfullCliLogger.verbose(response.body);
        throw ImpaktfullCliError(
            'Failed to upload chunk ($chunkProgress) to AppCenter');
      }
    }
  }

  Future<void> _finishUpload({
    required String packageAssetId,
    required String urlEncodedToken,
    required Secret apiToken,
  }) async {
    final finishedUrl =
        "$_appCenterFilesBaseUrl/upload/finished/$packageAssetId?token=$urlEncodedToken";
    final response = await http.post(
      Uri.parse(finishedUrl),
      headers: _getHeaders(apiToken),
    );
    if (response.statusCode != HttpStatus.ok) {
      ImpaktfullCliLogger.verbose(response.body);
      throw ImpaktfullCliError('Failed to finish upload to AppCenter');
    }
  }

  Future<void> _commitRelease({
    required String id,
    required String appName,
    required String ownerName,
    required Secret apiToken,
  }) async {
    final commitUrl =
        "$_appCenterApiBaseUrl/apps/$ownerName/$appName/uploads/releases/$id";
    final response = await http.patch(
      Uri.parse(commitUrl),
      headers: _getHeaders(apiToken),
      body: json.encode({
        "upload_status": "uploadFinished",
      }),
    );
    if (response.statusCode != HttpStatus.ok) {
      ImpaktfullCliLogger.verbose(response.body);
      throw ImpaktfullCliError('Failed to commit release to AppCenter');
    }
  }

  Future<int> _validateRelease({
    required String ownerName,
    required String appName,
    required String id,
    required Secret apiToken,
  }) async {
    final releaseStatusUrl =
        "$_appCenterApiBaseUrl/apps/$ownerName/$appName/uploads/releases/$id";

    int? releaseId;
    var counter = 0;
    const maxPollAttempts = 15;

    while (releaseId == null && counter < maxPollAttempts) {
      ImpaktfullCliLogger.log('Checking if release is ready...');
      final pollResult = await http.get(
        Uri.parse(releaseStatusUrl),
        headers: _getHeaders(apiToken),
      );
      final pollResultJson =
          json.decode(pollResult.body) as Map<String, dynamic>;
      releaseId = pollResultJson['release_distinct_id'] as int?;
      counter++;
      await Future.delayed(Duration(seconds: 3));
    }

    if (releaseId == null) {
      await cleanup();
      throw ImpaktfullCliError('Failed to find release from AppCenter');
    }
    return releaseId;
  }

  Future<String> _distributeRelease({
    required String ownerName,
    required String appName,
    required int releaseId,
    required List<String> distributionGroups,
    required bool notifyListeners,
    required Secret apiToken,
  }) async {
    final distributeUrl =
        "$_appCenterApiBaseUrl/apps/$ownerName/$appName/releases/$releaseId";
    final response = await http.patch(
      Uri.parse(distributeUrl),
      headers: _getHeaders(apiToken),
      body: json.encode({
        'destinations': distributionGroups
            .map((distributionGroup) => {'name': distributionGroup})
            .toList(),
        "notify_testers": notifyListeners,
      }),
    );
    if (response.statusCode != HttpStatus.ok) {
      ImpaktfullCliLogger.verbose(response.body);
      throw ImpaktfullCliError('Failed to distribute release to AppCenter');
    }
    return distributeUrl;
  }

  Map<String, String> _getHeaders(Secret apiToken) => {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'X-API-Token': apiToken.value,
      };

  Future<void> cleanup() async {
    final tempDirectory = Directory(_tempDirectoryPath);
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  }

  String _getAppTypeFor(File file) {
    final extension = file.path.split('.').last;
    if (_extensionMimeTypeMapper.containsKey(extension)) {
      return _extensionMimeTypeMapper[extension]!;
    }
    throw ImpaktfullCliError(
        'Extension `$extension` is not supported to upload to AppCenter using the impaktfull_cli');
  }
}
