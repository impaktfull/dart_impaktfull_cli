import 'package:args/args.dart';
import 'package:impaktfull_cli/src/apple_certificate/model/remove/apple_certificate_remove_config_data.dart';
import 'package:impaktfull_cli/src/cli/command/config/command_config.dart';
import 'package:impaktfull_cli/src/cli/util/extensions/arg_result_extensions.dart';

class AppleCertificateRemoveCommandConfig extends CommandConfig<AppleCertificateRemoveConfigData> {
  static const String _optionKeyChainName = 'keyChainName';
  final String defaultKeyChainName;
  AppleCertificateRemoveCommandConfig({
    required this.defaultKeyChainName,
  });
  @override
  void addConfig(ArgParser argParser) {
    argParser.addOption(
      _optionKeyChainName,
      help: 'Name of the keychain that should be created',
      defaultsTo: defaultKeyChainName,
    );
  }

  @override
  AppleCertificateRemoveConfigData parseResult(ArgResults? argResults) => AppleCertificateRemoveConfigData(
        keyChainName: argResults.getRequiredOption(_optionKeyChainName),
      );
}
