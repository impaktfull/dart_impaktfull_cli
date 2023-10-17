import 'package:impaktfull_cli/src/model/data/secret.dart';

class AppCenterBuildConfig {
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
      'Collaborators',
    ],
    this.notifyListeners = false,
  });
}
