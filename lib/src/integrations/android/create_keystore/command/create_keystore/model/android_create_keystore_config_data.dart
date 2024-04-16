import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class AndroidCreateKeyStoreConfigData extends ConfigData {
  final List<String> configNames;

  final String? fullName;
  final String? organization;
  final String? organizationUnit;
  final String? city;
  final String? state;
  final String? country;

  const AndroidCreateKeyStoreConfigData({
    required this.configNames,
    required this.fullName,
    required this.organization,
    required this.organizationUnit,
    required this.city,
    required this.state,
    required this.country,
  });
}
