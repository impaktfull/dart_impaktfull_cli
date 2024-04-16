import 'package:args/args.dart';
import 'package:impaktfull_cli/src/integrations/android/create_keystore/command/create_keystore/model/android_create_keystore_config_data.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';

class AndroidCreateKeyStoreCommandConfig
    extends CommandConfig<AndroidCreateKeyStoreConfigData> {
  static const String _optionConfigName = 'configName';
  static const String _optionFullName = 'fullName';
  static const String _optionOrganization = 'organization';
  static const String _optionOrganizationUnit = 'organizationUnit';
  static const String _optionCity = 'city';
  static const String _optionState = 'state';
  static const String _optionCountry = 'country';
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
      _optionFullName,
      help: 'Certificate info: Your full name',
      mandatory: true,
    );
    argParser.addOption(
      _optionOrganization,
      help: 'Certificate info: Your organization name',
      mandatory: true,
    );
    argParser.addOption(
      _optionOrganizationUnit,
      help: 'Certificate info: Your organization unit name',
    );
    argParser.addOption(
      _optionState,
      help: 'Certificate info: Your state name',
    );
    argParser.addOption(
      _optionCity,
      help: 'Certificate info: Your city name',
    );
    argParser.addOption(
      _optionCountry,
      help: 'Certificate info: Your country name',
      mandatory: true,
    );
  }

  @override
  AndroidCreateKeyStoreConfigData parseResult(ArgResults? argResults) =>
      AndroidCreateKeyStoreConfigData(
        configNames: argResults.getRequiredOption(_optionConfigName),
        fullName: argResults.getRequiredOptionOrAskInput<String>(
            _optionFullName, 'Enter your Full Name'),
        organization: argResults.getRequiredOptionOrAskInput<String>(
            _optionOrganization, 'Enter your Organization'),
        organizationUnit: argResults.getOptionOrAskInput<String>(
            _optionOrganizationUnit, 'Enter your Oranization Unit (optional)'),
        city: argResults.getOptionOrAskInput<String>(
            _optionCity, 'Enter your City (optional)'),
        state: argResults.getOptionOrAskInput(
            _optionState, 'Enter your State (optional)'),
        country: argResults.getRequiredOptionOrAskInput(
            _optionCountry, 'Enter the Country'),
      );
}
