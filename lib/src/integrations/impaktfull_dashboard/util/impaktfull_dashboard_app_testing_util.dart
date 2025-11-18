import 'dart:io';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_dashboard/model/impaktfull_dashboard_app_testing_version_upload_config.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_dashboard/util/impaktfull_dashboard_file_upload_util.dart';
import 'package:path/path.dart';

class ImpaktfullDashboardAppTestingUtil {
  static const allowedExtensions = ['apk', 'ipa', 'aab'];
  const ImpaktfullDashboardAppTestingUtil();
  Future<void> upload({
    required File file,
    required ImpaktfullDashboardAppTestingVersionUploadConfig config,
  }) async {
    final fileUploadUtil = ImpaktfullDashboardFileUploadUtil();
    final fileBytes = await file.readAsBytes();
    final params = {
      'appTestingAppUuid': config.appTestingAppUuid,
      'type': _getAppTestingAppType(file),
      'extensionType': _getExtensionType(file),
      'environmentName': config.environmentName,
    };
    await fileUploadUtil.uploadFile(
      'serverpod_cloud_storage',
      'upload',
      params,
      config.credentials.apiKey.value,
      fileBytes,
    );
  }

  String _getExtensionType(File file) {
    final fileExtension = _getFileExtension(file);
    if (!allowedExtensions.contains(fileExtension)) {
      throw ImpaktfullCliError(
        'Extension `$fileExtension` is not supported to upload to Impaktfull Dashboard using the impaktfull_cli, allowed extensions are: $allowedExtensions',
      );
    }
    return fileExtension;
  }

  String _getAppTestingAppType(File file) {
    final fileExtension = _getFileExtension(file);
    switch (fileExtension) {
      case 'apk':
      case 'aab':
        return 'android';
      case 'ipa':
        return 'ios';
      default:
        throw ImpaktfullCliError(
          'Extension `$fileExtension` is not supported to upload to Impaktfull Dashboard using the impaktfull_cli, allowed extensions are: $allowedExtensions',
        );
    }
  }

  String _getFileExtension(File file) {
    final fileExtension = extension(file.path);
    return fileExtension.replaceAll('.', '');
  }
}
