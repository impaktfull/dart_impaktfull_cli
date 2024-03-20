import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class AndroidCreateKeyStoreConfigData extends ConfigData {
  final List<String> configNames;

  final String? dNameFullName;
  final String? dNameOrganization;
  final String? dNameOrganizationUnit;
  final String? dNameCity;
  final String? dNameState;
  final String? dNameCountry;

  const AndroidCreateKeyStoreConfigData({
    required this.configNames,
    required this.dNameFullName,
    required this.dNameOrganization,
    required this.dNameOrganizationUnit,
    required this.dNameCity,
    required this.dNameState,
    required this.dNameCountry,
  });
}
