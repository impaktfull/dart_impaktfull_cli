import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/util/case/case_util.dart';
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
    await processRunner.requestSudo();
    await validateZshrc();
    await installHomebrew();
    await installCocoapods();
    await installOhMyZsh();
    await installAutosuggestions();
  }

  Future<void> validateZshrc() async {
    ImpaktfullCliLogger.startSpinner("Validate zshrc");
    await zshrcUtil.validateZshrc();
  }

  Future<void> installHomebrew() async {
    ImpaktfullCliLogger.startSpinner("Adding homebrew to PATH");
    await zshrcUtil.addToPath(
      comment: r'Add homebrew to PATH',
      pathsToAdd: [
        r"/opt/homebrew/bin",
      ],
    );
    ImpaktfullCliLogger.startSpinner("Installing homebrew");
    if (ImpaktfullCliEnvironment.isInstalled(CliTool.brew)) {
      ImpaktfullCliLogger.endSpinnerWithMessage(
          "Homebrew is already installed");
      return;
    }
    await processRunner.runProcess(
      [
        '/bin/bash',
        '-c',
        r'/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
      ],
      runInShell: true,
    );
  }

  Future<void> installCocoapods() async {
    if (ImpaktfullCliEnvironment.isInstalled(CliTool.cocoaPods)) {
      ImpaktfullCliLogger.endSpinnerWithMessage(
          "Cocoapods is already installed");
      return;
    }
    ImpaktfullCliLogger.startSpinner("Installing cocoapods");
    await processRunner.runProcess([
      'brew',
      'install',
      'cocoapods',
    ]);
  }

  Future<void> installOhMyZsh() async {
    ImpaktfullCliLogger.startSpinner("Installing oh-my-zsh");
    final dir = Directory(join(
        ImpaktfullCliEnvironmentVariables.getEnvVariable("HOME"),
        '.oh-my-zsh'));
    if (dir.existsSync()) {
      ImpaktfullCliLogger.endSpinnerWithMessage(
          "Oh-my-zsh is already installed");
      return;
    }
    await processRunner.runProcess(
      [
        '/bin/bash',
        '-c',
        r'sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"',
      ],
      runInShell: true,
    );
    await zshrcUtil.addImpaktfullZshrcToZshrc();
  }

  Future<void> installAutosuggestions() async {
    ImpaktfullCliLogger.startSpinner("Installing zsh-autosuggestions");
    await processRunner.runProcess(
      [
        'brew',
        'install',
        'zsh-autosuggestions',
      ],
    );
    await zshrcUtil.addToZshrc(
      comment: r'Add zsh-autosuggestions',
      content:
          r'source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh',
    );
  }

  @override
  Future<void> installChrome() async {
    final path = Directory('/Applications/Google Chrome.app');
    if (path.existsSync()) {
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
    ImpaktfullCliLogger.startSpinner("Adding fvm & flutter paths to PATH");
    await zshrcUtil.addToPath(
      comment: "Add fvm & flutter paths to PATH variable",
      pathsToAdd: [
        r"$HOME/.pub-cache/bin",
        r"$HOME/.pub-cache",
        r"$HOME/fvm/default/bin",
        r"$HOME/fvm/default/bin/dart/bin",
        r"$HOME/fvm/default/bin/dart/bin/dart2js",
        r"$HOME/fvm/default/bin/dart/bin/pub",
      ],
    );
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
  }

  @override
  Future<void> installAdditionalTools() async {
    await installRaycast();
    await selectXcode();
  }

  Future<void> installRaycast() async {
    ImpaktfullCliLogger.startSpinner("Installing raycast");
    final path = Directory(join('/Applications', 'Raycast.app'));
    if (path.existsSync()) {
      ImpaktfullCliLogger.endSpinnerWithMessage("Raycast is already installed");
      return;
    }
    await processRunner.runProcess([
      'brew',
      'install',
      '--cask',
      'raycast',
    ]);
    ImpaktfullCliLogger.log(
        "Make sure to disable Spotlight in the keyboard shortcut. And configure Raycast at first startup");
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
      await printSshPublicKey(sshPublicKeyFile);
      ImpaktfullCliLogger.endSpinnerWithMessage("SSH key already exists");
      return;
    }
    await processRunner.runProcess([
      'ssh-keygen',
      '-t',
      'ed25519',
      '-C',
      '${CaseUtil.kebabCaseToSnakeCase(userName)}@impaktfull.com',
      '-N',
      '',
      '-f',
      sshPrivateKeyFile.path,
    ]);
    if (!sshPrivateKeyFile.existsSync()) {
      throw ImpaktfullCliError("Private ssh key not found");
    }

    if (!sshPublicKeyFile.existsSync()) {
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
    await printSshPublicKey(sshPublicKeyFile);
  }

  Future<void> printSshPublicKey(File sshPublicKeyFile) async {
    ImpaktfullCliLogger.startSpinner("Export ssh public key");
    final sshPublicKeyContent = sshPublicKeyFile.readAsStringSync();
    ImpaktfullCliLogger.log("\nPublic ssh key:");
    ImpaktfullCliLogger.log(sshPublicKeyContent.trim());
    ImpaktfullCliLogger.log("\n");
    ImpaktfullCliLogger.log("Add the public ssh key to your github account");
    ImpaktfullCliLogger.log("https://github.com/settings/ssh/new");
    ImpaktfullCliLogger.log("\n");
    ImpaktfullCliLogger.stopSpinner();
    ImpaktfullCliLogger.waitForEnter(
        "Configure github to use the ssh key. Press enter to continue:");
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

  @override
  Future<void> validation() async {
    ImpaktfullCliLogger.startSpinner("Verifying Flutter");
    final result = await processRunner.runProcess(['flutter', 'doctor', '-v']);
    ImpaktfullCliLogger.endSpinnerWithMessage('Verifying Flutter: $result');

    ImpaktfullCliLogger.startSpinner("Verifying Cocoapods");
    final cocoapodsVersion =
        await processRunner.runProcess(['pod', '--version']);
    ImpaktfullCliLogger.endSpinnerWithMessage(
        "Verifying Cocoapods: $cocoapodsVersion");
  }

  Future<void> selectXcode() async {
    ImpaktfullCliLogger.startSpinner("Selecting Xcode");
    final path = Directory('/Applications/Xcode.app/Contents/Developer');
    if (!path.existsSync()) {
      final message = [
        "Xcode is not installed.",
        "Install Xcode here: https://developer.apple.com/download/all/?q=xcode",
        "If installed press enter to continue",
      ].join('\n\n');
      ImpaktfullCliLogger.waitForEnter(message);
    }
    await processRunner.runProcess(['xcode-select', path.path]);
    final xcode =
        await processRunner.runProcess(['xcode-select', '--print-path']);
    ImpaktfullCliLogger.endSpinnerWithMessage("Selecting Xcode: $xcode");
    ImpaktfullCliLogger.log("Xcode path: $path");
  }
}
