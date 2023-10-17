import 'package:args/args.dart';
import 'package:impaktfull_cli/src/command/cli_command.dart';
import 'package:impaktfull_cli/src/plugin/mac_os/keychain/mac_os_keychain_plugin.dart';
import 'package:impaktfull_cli/src/util/extensions/args_extensions.dart';

class RemoveAppleCertificateCommand
    extends CliCommand<RemoveAppleCertificateArgs> {
  static const _optionKeyChainName = 'keychain-name';

  const RemoveAppleCertificateCommand();

  @override
  String get name => 'remove-apple-certificate';

  @override
  ArgParser get argParser => ArgParser()
    ..addOption(
      _optionKeyChainName,
      help: 'Name of the keychain that should be removed',
      mandatory: true,
    );

  @override
  Future<RemoveAppleCertificateArgs> convertToParams(
          ArgParser originalArgParser, ArgResults results) async =>
      RemoveAppleCertificateArgs(
        keyChainName: results.getRequiredOption(_optionKeyChainName),
      );

  @override
  Future<void> runCommand(RemoveAppleCertificateArgs params) async {
    final keyChainPlugin = MacOsKeyChainPlugin();
    await keyChainPlugin.removeKeyChain(params.keyChainName);
  }
}

class RemoveAppleCertificateArgs {
  final String keyChainName;

  const RemoveAppleCertificateArgs({
    required this.keyChainName,
  });
}
