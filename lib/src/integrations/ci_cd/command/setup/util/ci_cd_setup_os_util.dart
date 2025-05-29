import 'package:impaktfull_cli/impaktfull_cli.dart';

abstract class CiCdSetupOsUtil {
  final ProcessRunner processRunner;

  CiCdSetupOsUtil({
    required this.processRunner,
  });

  Future<void> install() async {
    final name = ImpaktfullCliLogger.askQuestion("Name your CI/CD device");
    validateName(name);
    ImpaktfullCliLogger.startSpinner("Installing dependencies");
    await installOsDependencies();
    await installChrome();
    await installFvm();
    final flutterVersion = "stable";
    await installFlutterVersion(flutterVersion);
    await setFlutterVersionAsGlobal(flutterVersion);
    await configureSSHKey(name!);
    ImpaktfullCliLogger.startSpinner("Installing github actions runner");
    await installGithubActionsRunner();
  }

  void validateName(String? name) {
    if (name == null) {
      throw ImpaktfullCliError("Name is required");
    }
    final validMacUsernameRegex = RegExp(r'^[a-z][a-z0-9_]*$');
    if (!validMacUsernameRegex.hasMatch(name)) {
      throw ImpaktfullCliError(
          "Name must start with a lowercase letter and can only contain lowercase letters, numbers and underscores");
    }
  }

  Future<void> installOsDependencies();

  Future<void> installChrome();

  Future<void> installFvm();

  Future<void> installGithubActionsRunner();

  Future<void> installFlutterVersion(String version) async {
    ImpaktfullCliLogger.startSpinner("Installing flutter version `$version`");
    // Install stable version of flutter + make sure it ready to use
    await processRunner.runProcess([
      'fvm',
      'install',
      version,
      '--setup',
    ]);
  }

  Future<void> setFlutterVersionAsGlobal(String version) async {
    ImpaktfullCliLogger.startSpinner(
        "Setting flutter version `$version` as global");
    await processRunner.runProcess([
      'fvm',
      'global',
      version,
    ]);
  }

  Future<void> configureSSHKey(String userName);
}
