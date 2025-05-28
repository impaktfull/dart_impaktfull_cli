import 'package:impaktfull_cli/impaktfull_cli.dart';

abstract class CiCdSetupOsUtil {
  final ProcessRunner processRunner;

  CiCdSetupOsUtil({
    required this.processRunner,
  });

  Future<void> install(Secret sudoPassword) async {
    ImpaktfullCliLogger.log("Installing dependencies");
    await installOsDependencies(sudoPassword);
    ImpaktfullCliLogger.log("Installing chrome");
    await installChrome();
    ImpaktfullCliLogger.log("Installing fvm");
    await installFvm();
    ImpaktfullCliLogger.log("Installing flutter version");
    await installFlutterVersion("stable");
    ImpaktfullCliLogger.log("Setting flutter version as global");
    await setFlutterVersionAsGlobal("stable");
    ImpaktfullCliLogger.log("Installing github actions runner");
    await installGithubActionsRunner();
  }

  Future<void> installOsDependencies(Secret sudoPassword);

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
