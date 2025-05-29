import 'package:impaktfull_cli/impaktfull_cli.dart';

abstract class CiCdSetupOsUtil {
  final ProcessRunner processRunner;

  CiCdSetupOsUtil({
    required this.processRunner,
  });

  Future<void> install() async {
    ImpaktfullCliLogger.startSpinner("Installing dependencies");
    await installOsDependencies();
    ImpaktfullCliLogger.startSpinner("Installing chrome");
    await installChrome();
    ImpaktfullCliLogger.startSpinner("Installing fvm");
    await installFvm();
    final flutterVersion = "stable";
    ImpaktfullCliLogger.startSpinner("Installing flutter version `$flutterVersion`");
    await installFlutterVersion(flutterVersion);
    ImpaktfullCliLogger.startSpinner("Setting flutter version `$flutterVersion` as global");
    await setFlutterVersionAsGlobal(flutterVersion);
    ImpaktfullCliLogger.startSpinner("Installing github actions runner");
    await installGithubActionsRunner();
  }

  Future<void> installOsDependencies();

  Future<void> installChrome();

  Future<void> installFvm();

  Future<void> installGithubActionsRunner();

  Future<void> installFlutterVersion(String version) async {
    // Install stable version of flutter + make sure it ready to use
    await processRunner.runProcess([
      'fvm',
      'install',
      version,
      '--setup',
    ]);
  }

  Future<void> setFlutterVersionAsGlobal(String version) async {
    await processRunner.runProcess([
      'fvm',
      'global',
      version,
    ]);
  }
}
