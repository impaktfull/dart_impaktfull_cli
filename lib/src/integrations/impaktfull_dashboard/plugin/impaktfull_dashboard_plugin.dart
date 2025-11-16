import 'dart:io';

import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_dashboard/model/impaktfull_dashboard_app_testing_version_upload_config.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_dashboard/util/impaktfull_dashboard_app_testing_util.dart';

class ImpaktfullDashboardPlugin extends ImpaktfullCliPlugin {
  const ImpaktfullDashboardPlugin({
    required super.processRunner,
  });

  Future<void> uploadAppTestingVersionToImpaktfullDashboard({
    required File file,
    required ImpaktfullDashboardAppTestingVersionUploadConfig config,
  }) async {
    ImpaktfullCliLogger.setSpinnerPrefix(
        'Impaktfull Dashboard app testing version upload');
    ImpaktfullCliLogger.startSpinner('Uploading');
    const appTestingUtil = ImpaktfullDashboardAppTestingUtil();
    await appTestingUtil.upload(
      file: file,
      config: config,
    );
    ImpaktfullCliLogger.clearSpinnerPrefix();
  }
}
