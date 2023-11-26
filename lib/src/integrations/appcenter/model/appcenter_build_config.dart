import 'package:impaktfull_cli/src/core/model/data/secret.dart';

class AppCenterBuildConfig {
  static const defaultDistributionGroup = 'Collaborators';
  final String appName;
  final String? ownerName;
  final Secret? apiToken;
  final List<String> distributionGroups;
  final bool notifyListeners;

  const AppCenterBuildConfig({
    required this.appName,
    this.ownerName,
    this.apiToken,
    this.distributionGroups = const [
      defaultDistributionGroup,
    ],
    this.notifyListeners = false,
  });
}
