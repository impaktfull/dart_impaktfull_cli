import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/setup/util/ci_cd_setup_os_util.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/setup/util/macos/ci_cd_setup_mac_zshrc_util.dart';
import 'package:path/path.dart';

class CiCdSetupMacUtil extends CiCdSetupOsUtil {
  final CiCdSetupMacZshrcUtil zshrcUtil;

  CiCdSetupMacUtil({
    required this.zshrcUtil,
    required super.processRunner,
  });

  @override
  Future<void> installOsDependencies() async {
    await validateZshrc();
    await installHomebrew();
    await installAutosuggestions();
  }

  Future<void> validateZshrc() async {
    ImpaktfullCliLogger.startSpinner("Validate zshrc");
    await zshrcUtil.validateZshrc();
  }

  Future<void> installHomebrew() async {
    ImpaktfullCliLogger.startSpinner("Installing homebrew");
    if (ImpaktfullCliEnvironment.isInstalled(CliTool.brew)) {
      ImpaktfullCliLogger.endSpinnerWithMessage(
          "Homebrew is already installed");
      return;
    }
    await processRunner.requestSudo();
    await processRunner.runProcess(
      [
        '/bin/bash',
        '-c',
        '/bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
      ],
      runInShell: true,
    );
    ImpaktfullCliLogger.startSpinner("Adding homebrew to .zshrc");
    await zshrcUtil.addToZshrc(
      r'Add homebrew to PATH',
      r'export PATH="/opt/homebrew/bin:$PATH"',
    );
  }

  Future<void> installAutosuggestions() async {
    ImpaktfullCliLogger.startSpinner("Installing zsh-autosuggestions");
    await processRunner.runProcess(
      [
        '/bin/bash',
        '-c',
        '/bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
      ],
      runInShell: true,
    );
    await zshrcUtil.addToZshrc(
      r'Add zsh-autosuggestions',
      r'source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh',
    );
  }

  @override
  Future<void> installChrome() async {
    final path = '/Applications/Google Chrome.app';
    if (Directory(path).existsSync()) {
      ImpaktfullCliLogger.endSpinnerWithMessage("Chrome is already installed");
      return;
    }
    await processRunner.runProcess([
      'brew',
      'install',
      'google-chrome',
    ]);
  }

  @override
  Future<void> installFvm() async {
    ImpaktfullCliLogger.startSpinner("Installing fvm");
    if (ImpaktfullCliEnvironment.isInstalled(CliTool.fvm)) {
      ImpaktfullCliLogger.endSpinnerWithMessage("FVM is already installed");
      return;
    }
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
    final content = r"""
export PATH=$PATH:$HOME/.pub-cache/bin
export PATH=$PATH:$HOME/.pub-cache
export PATH=$PATH:$HOME/fvm/default/bin
export PATH=$PATH:$HOME/fvm/default/bin/dart/bin
export PATH=$PATH:$HOME/fvm/default/bin/dart/bin/dart2js
export PATH=$PATH:$HOME/fvm/default/bin/dart/bin/pub
""";
    await zshrcUtil.addToZshrc(
      "Add fvm paths to PATH variable",
      content,
    );
  }

  @override
  Future<void> configureSSHKey(String userName) async {
    ImpaktfullCliLogger.startSpinner("Creating new `ed25519` ssh key");
    final sshConfigFile = File(join(
        ImpaktfullCliEnvironmentVariables.getEnvVariable("HOME"),
        '.ssh',
        'config'));
    final sshPrivateKeyFile = File(join(
        ImpaktfullCliEnvironmentVariables.getEnvVariable("HOME"),
        '.ssh',
        'id_ed25519'));
    final sshPublicKeyFile = File(join(
        ImpaktfullCliEnvironmentVariables.getEnvVariable("HOME"),
        '.ssh',
        'id_ed25519.pub'));

    if (sshPrivateKeyFile.existsSync()) {
      ImpaktfullCliLogger.endSpinnerWithMessage("SSH key already exists");
      return;
    }
    await processRunner.runProcess([
      'ssh-keygen',
      '-t',
      'ed25519',
      '-C',
      '$userName@impaktfull.com',
      '-N',
      '',
      '-f',
      sshPrivateKeyFile.path,
    ]);
    if (!sshPrivateKeyFile.existsSync()) {
      throw ImpaktfullCliError("Private ssh key not found");
    }

    if (sshPublicKeyFile.existsSync()) {
      throw ImpaktfullCliError("Public ssh key not found");
    }

    ImpaktfullCliLogger.startSpinner("Add ssh key to .ssh/config");
    if (!sshConfigFile.existsSync()) {
      sshConfigFile.createSync(recursive: true);
    }
    final sshConfigContent = """
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_github
"""
        .trim();
    sshConfigFile.writeAsStringSync(sshConfigContent);

    ImpaktfullCliLogger.startSpinner("Export ssh public key");
    final sshPublicKeyContent = sshPublicKeyFile.readAsStringSync();
    ImpaktfullCliLogger.log("\nPublic ssh key:");
    ImpaktfullCliLogger.log(sshPublicKeyContent);
    ImpaktfullCliLogger.log("\n");
    ImpaktfullCliLogger.log("Add the public ssh key to your github account");
    ImpaktfullCliLogger.log("https://github.com/settings/ssh/new");
    ImpaktfullCliLogger.log("\n");
    ImpaktfullCliLogger.stopSpinner();
    ImpaktfullCliLogger.waitForEnter(
        "Did you add the public ssh key to your github account?");
  }

  @override
  Future<void> installGithubActionsRunner() async {
    ImpaktfullCliLogger.startSpinner("Installing github actions runner");
    ImpaktfullCliLogger.log("\n\n");
    ImpaktfullCliLogger.log("Start github actions runner config");
    ImpaktfullCliLogger.log(
        "https://github.com/organizations/impaktfull/settings/actions/runners/new?arch=arm64&os=osx");
    ImpaktfullCliLogger.log("\nConfigure runner as service");
    ImpaktfullCliLogger.log(
        "https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service?platform=mac");
    ImpaktfullCliLogger.log("\n");
  }
}
