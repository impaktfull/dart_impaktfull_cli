import 'package:impaktfull_cli/src/core/model/data/secret.dart';

class ImpaktfullDashboardCredentials {
  /// api key to authenticate to impaktfull dashboard
  final Secret apiKey;

  const ImpaktfullDashboardCredentials({
    required this.apiKey,
  });
}
