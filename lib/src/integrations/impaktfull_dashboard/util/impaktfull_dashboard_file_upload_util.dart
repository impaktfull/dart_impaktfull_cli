import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:http/http.dart' as http;

const _impaktfullDashboardApiBaseUrl = 'https://api.dashboard.impaktfull.com/';

class ImpaktfullDashboardFileUploadUtil {
  const ImpaktfullDashboardFileUploadUtil();

  Future<Map<String, dynamic>> uploadFile(
    String endpointName,
    String apiPath,
    Map<String, dynamic> params,
    String apiKey,
    Uint8List byteData,
  ) async {
    final hostUri = Uri.parse(_impaktfullDashboardApiBaseUrl);
    var uri = Uri(
      scheme: hostUri.scheme,
      host: hostUri.host,
      port: hostUri.port,
      path: endpointName,
      queryParameters: {
        'method': apiPath,
        ...params,
      },
    );

    final stream = http.ByteStream.fromBytes(Uint8List.sublistView(byteData));
    final streamLength = byteData.length;

    final request = http.StreamedRequest('POST', uri);
    request.headers.addAll({
      'Content-Type': 'application/octet-stream',
      'Accept': '*/*',
      'X-IF-APP-TESTING-APP-API-KEY': apiKey,
    });
    request.contentLength = streamLength;
    unawaited(stream.pipe(request.sink));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw ImpaktfullCliError(
          'Failed to upload file: ${response.statusCode} - $body');
    }
    return json;
  }
}
