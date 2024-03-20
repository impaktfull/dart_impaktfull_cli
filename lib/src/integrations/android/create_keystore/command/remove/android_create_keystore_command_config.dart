import 'package:args/args.dart';
import 'package:impaktfull_cli/src/integrations/android/create_keystore/command/remove/model/android_create_keystore_config_data.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';

class AndroidCreateKeyStoreCommandConfig
    extends CommandConfig<AndroidCreateKeyStoreConfigData> {
  static const String _optionConfigName = 'configName';
  static const String _optionDNameFullName = 'dNameFullName';
  static const String _optionDNameOrganization = 'dNameOrganization';
  static const String _optionDNameOrganizationUnit = 'dNameOrganizationUnit';
  static const String _optionDNameCity = 'dNameCity';
  static const String _optionDNameState = 'dNameState';
  static const String _optionDNameCountry = 'dNameCountry';
  static const defaultSigningConfigNames = ['debug', 'release'];

  const AndroidCreateKeyStoreCommandConfig();

  @override
  void addConfig(ArgParser argParser) {
    argParser.addMultiOption(
      _optionConfigName,
      help: 'Signing config name',
      defaultsTo: defaultSigningConfigNames,
    );
    argParser.addOption(
      _optionDNameFullName,
      help: 'Certificate info: Your full name',
      mandatory: true,
    );
    argParser.addOption(
      _optionDNameOrganization,
      help: 'Certificate info: Your organization name',
      mandatory: true,
    );
    argParser.addOption(
      _optionDNameOrganizationUnit,
      help: 'Certificate info: Your organization unit name',
    );
    argParser.addOption(
      _optionDNameState,
      help: 'Certificate info: Your state name',
    );
    argParser.addOption(
      _optionDNameCity,
      help: 'Certificate info: Your city name',
    );
    argParser.addOption(
      _optionDNameCountry,
      help: 'Certificate info: Your country name',
      mandatory: true,
    );
  }

  @override
  AndroidCreateKeyStoreConfigData parseResult(ArgResults? argResults) =>
      AndroidCreateKeyStoreConfigData(
        configNames: argResults.getRequiredOption(_optionConfigName),
        dNameFullName: argResults.getRequiredOptionOrAskInput<String>(
            _optionDNameFullName, 'Enter your Full Name'),
        dNameOrganization: argResults.getRequiredOptionOrAskInput<String>(
            _optionDNameOrganization, 'Enter your Organization'),
        dNameOrganizationUnit: argResults.getOptionOrAskInput<String>(
            _optionDNameOrganizationUnit,
            'Enter your Oranization Unit (optional)'),
        dNameCity: argResults.getOptionOrAskInput<String>(
            _optionDNameCity, 'Enter your City (optional)'),
        dNameState: argResults.getOptionOrAskInput(
            _optionDNameState, 'Enter your State (optional)'),
        dNameCountry: argResults.getRequiredOptionOrAskInput(
            _optionDNameCountry, 'Enter the Country'),
      );
}
