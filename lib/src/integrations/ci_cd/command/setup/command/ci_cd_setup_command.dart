import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/command/command/cli_command.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/setup/command/ci_cd_setup_command_config.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/setup/command/model/ci_cd_setup_config_data.dart';

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
    await installHomebrew(sudoPassword);
    await installChrome();
    await installGithubActionsRunner();
    await installFvm();
    await installFlutterStable("stable");
  }

  Future<void> installHomebrew(Secret sudoPassword) async {
    await processRunner.runProcess([
      '/bin/bash',
      '-c',
      r'$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)',
    ]);
    await processRunner.runProcess([
      'echo',
      r'export PATH="/opt/homebrew/bin:$PATH" >> ~/.zshrc',
    ]);
  }

  Future<void> installChrome() async {
    await processRunner.runProcess([
      'brew',
      'install',
      'google-chrome',
    ]);
  }

  Future<void> installGithubActionsRunner() async {
    // echo "Start Github actions runner config"
    // https://github.com/organizations/impaktfull/settings/actions/runners/new?arch=arm64&os=osx
    //
    // echo "Configure runner as service"
    // https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service?platform=mac
  }

  Future<void> installFvm() async {
    await processRunner.runProcess([
      'brew',
      'tap',
      'leoafarias/fvm',
    ]);
    await processRunner.runProcess([
      'brew',
      'install',
      'fvm',
    ]);
  }

  Future<void> installFlutterStable(String version) async {
    // Install stable version of flutter + make sure it ready to use
    await processRunner.runProcess([
      'fvm',
      'install',
      'stable',
      '--setup',
    ]);

    // Set stable as default fvm version
    await processRunner.runProcess([
      'fvm',
      'use',
      version,
    ]);
  }
}
