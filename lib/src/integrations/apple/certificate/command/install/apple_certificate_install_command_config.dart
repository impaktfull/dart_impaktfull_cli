import 'package:args/args.dart';
import 'package:impaktfull_cli/src/integrations/apple/certificate/model/install/apple_certificate_install_config_data.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';

class AppleCertificateInstallCommandConfig
    extends CommandConfig<AppleCertificateInstallConfigData> {
  static const String _optionOnePasswordUuid = 'onePasswordUuid';
  static const String _optionKeyChainName = 'keyChainName';
  final String defaultKeyChainName;

  const AppleCertificateInstallCommandConfig({
    required this.defaultKeyChainName,
  });

  @override
  void addConfig(ArgParser argParser) {
    argParser
      ..addOption(
        _optionOnePasswordUuid,
        mandatory: true,
        help: '1Password UUID',
      )
      ..addOption(
        _optionKeyChainName,
        help: 'Name of the keychain that should be created',
        defaultsTo: defaultKeyChainName,
      );
  }

  @override
  AppleCertificateInstallConfigData parseResult(ArgResults? argResults) =>
      AppleCertificateInstallConfigData(
        onePasswordUuid: argResults.getRequiredOption(_optionOnePasswordUuid),
        keyChainName: argResults.getRequiredOption(_optionKeyChainName),
      );
}
