import 'package:impaktfull_cli/impaktfull_cli.dart';

abstract class CiCdSetupOsUtil {
  final ProcessRunner processRunner;

  CiCdSetupOsUtil({
    required this.processRunner,
  });

  Future<void> install(Secret sudoPassword) async {
    await installOsDependencies(sudoPassword);
    await installChrome();
    await installFvm();
    await installFlutterVersion("stable");
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
