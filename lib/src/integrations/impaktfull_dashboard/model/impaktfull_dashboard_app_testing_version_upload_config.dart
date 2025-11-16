import 'package:impaktfull_cli/src/integrations/impaktfull_dashboard/model/impaktfull_dashboard_credentials.dart';

class ImpaktfullDashboardAppTestingVersionUploadConfig {
  /// credentials to authenticate to impaktfull dashboard
  final ImpaktfullDashboardCredentials credentials;

  /// Id of the app testing version to upload
  final String appTestingAppUuid;

  /// Name of the environment to upload the app testing version to
  /// Usually the environments are named like "alpha" or "beta" or "prod"
  /// Similar to the flavor name we already know from flutter
  final String environmentName;

  const ImpaktfullDashboardAppTestingVersionUploadConfig({
    required this.credentials,
    required this.appTestingAppUuid,
    required this.environmentName,
  });
}
