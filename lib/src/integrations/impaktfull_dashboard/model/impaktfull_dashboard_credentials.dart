import 'package:impaktfull_cli/src/core/model/data/secret.dart';

@Deprecated(
  'App Testing in the impaktfull dashboard is replaced by the impaktfull appstore. Use ImpaktfullAppstorePlugin instead.',
)
class ImpaktfullDashboardCredentials {
  /// api key to authenticate to impaktfull dashboard
  final Secret apiKey;

  const ImpaktfullDashboardCredentials({
    required this.apiKey,
  });
}
