import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/setup/command/ci_cd_setup_command_config.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/setup/command/model/ci_cd_setup_config_data.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/setup/util/ci_cd_setup_mac_util.dart';

class CiCdSetupCommand extends CliCommand<CiCdSetupConfigData> {
  CiCdSetupCommand({
    required super.processRunner,
  });

  @override
  String get name => 'setup';

  @override
  String get description => 'Setup a new CI/CD device';

  @override
  CommandConfig<CiCdSetupConfigData> getConfig() => CiCdSetupCommandConfig();

  @override
  Future<void> runCommand(CiCdSetupConfigData configData) async {
    final sudoPassword = CliInputReader.readSecret('Enter sudo password');

    if (Platform.isMacOS) {
      await CiCdSetupMacUtil(processRunner: processRunner).install(sudoPassword);
    } else {
      throw Exception('Unsupported platform: ${Platform.operatingSystem}');
    }
  }
}
