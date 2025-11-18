import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment_variables.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';

class MacOsKeyChainPlugin extends ImpaktfullCliPlugin {
  const MacOsKeyChainPlugin({
    super.processRunner = const CliProcessRunner(),
  });

  String _fullKeyChainName(String keyChainName) => '$keyChainName.keychain';

  Future<void> unlockKeyChain({
    String name = 'login',
    Secret? password,
  }) async {
    final fullName = _fullKeyChainName(name);
    final unlockPassword = password ??
        ImpaktfullCliEnvironmentVariables.getUnlockKeyChainPassword();
    await processRunner.runProcess([
      'security',
      'unlock-keychain',
      '-p',
      unlockPassword.value,
      fullName,
    ]);
  }
}
