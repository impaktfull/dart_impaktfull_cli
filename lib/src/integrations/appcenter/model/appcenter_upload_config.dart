import 'package:impaktfull_cli/src/core/model/data/secret.dart';

@Deprecated(
  'App Center was retired by Microsoft in March 2025. Use ImpaktfullAppstorePlugin (impaktfull appstore) instead.',
)
class AppCenterUploadConfig {
  static const defaultDistributionGroup = 'Collaborators';

  final String appName;
  final String? ownerName;
  final Secret? apiToken;
  final List<String> distributionGroups;
  final bool notifyListeners;

  const AppCenterUploadConfig({
    required this.appName,
    this.ownerName,
    this.apiToken,
    this.distributionGroups = const [
      defaultDistributionGroup,
    ],
    this.notifyListeners = false,
  });
}
