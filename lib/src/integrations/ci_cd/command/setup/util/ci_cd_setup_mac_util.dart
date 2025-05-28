import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/setup/util/ci_cd_setup_os_util.dart';

class CiCdSetupMacUtil extends CiCdSetupOsUtil {
  CiCdSetupMacUtil({required super.processRunner});

  @override
  Future<void> installOsDependencies(Secret sudoPassword) async {
    await installHomebrew(sudoPassword);
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

  @override
  Future<void> installChrome() async {
    await processRunner.runProcess([
      'brew',
      'install',
      'google-chrome',
    ]);
  }

  @override
  Future<void> installGithubActionsRunner() async {
    ImpaktfullCliLogger.log("Start github actions runner config");
    ImpaktfullCliLogger.log(
        "https://github.com/organizations/impaktfull/settings/actions/runners/new?arch=arm64&os=osx");
    ImpaktfullCliLogger.log("");
    ImpaktfullCliLogger.log("Configure runner as service");
    ImpaktfullCliLogger.log(
        "https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service?platform=mac");
  }

  @override
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
}
