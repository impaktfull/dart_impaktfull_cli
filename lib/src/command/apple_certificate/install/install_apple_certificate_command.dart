import 'package:args/args.dart';
import 'package:impaktfull_cli/src/command/cli_command.dart';
import 'package:impaktfull_cli/src/model/data/secret.dart';
import 'package:impaktfull_cli/src/util/extensions/args_extensions.dart';

class InstallAppleCertificateCommand
    extends CliCommand<InstallAppleCertificateArgs> {
  static const _optionOnePasswordUuid = 'op-uuid';
  static const _optionKeyChainName = 'keychain-name';

  const InstallAppleCertificateCommand();

  @override
  String get name => 'install-apple-certificate';

  @override
  ArgParser get argParser => ArgParser()
    ..addOption(
      _optionOnePasswordUuid,
      mandatory: true,
      help: '1Password UUID',
    )
    ..addOption(
      _optionKeyChainName,
      mandatory: true,
      help:
          'Name of the keychain that should be created, (Defaults to --$_optionOnePasswordUuid)',
    );

  @override
  Future<InstallAppleCertificateArgs> convertToParams(
      ArgParser originalArgParser, ArgResults results) async {
    return InstallAppleCertificateArgs(
      onePasswordUuid: results.getRequiredOption(_optionOnePasswordUuid),
      keyChainName: results.getRequiredOption(_optionKeyChainName),
    );
  }

  @override
  Future<void> runCommand(InstallAppleCertificateArgs params) async {}
}

class InstallAppleCertificateArgs {
  final Secret onePasswordUuid;
  final String keyChainName;

  const InstallAppleCertificateArgs({
    required this.onePasswordUuid,
    required this.keyChainName,
  });
}
