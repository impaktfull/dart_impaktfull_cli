import 'package:impaktfull_cli/impaktfull_cli.dart';

import 'example_config.dart';

Future<void> main(List<String> arguments) async {
  await runImpaktfullCli(
    () async {
      final processRunner = CliProcessRunner();
      final keyChainPlugin = MacOsKeyChainPlugin(processRunner: processRunner);
      final keyChainName = ExampleConfig.keyChainName;
      final globalKeyChainPasswordSecret = ExampleConfig.globalKeyChainPassword;

      await keyChainPlugin.printKeyChainList();
      await keyChainPlugin.createKeyChain(
          keyChainName, globalKeyChainPasswordSecret);
      await keyChainPlugin.printKeyChainList();
      await keyChainPlugin.unlockKeyChain(
          keyChainName, globalKeyChainPasswordSecret);

      CliLogger.debug('Execute build');
      await Future.delayed(const Duration(seconds: 5));

      await keyChainPlugin.printKeyChainList();
      await keyChainPlugin.removeKeyChain(keyChainName);
      await keyChainPlugin.printKeyChainList();
    },
    isVerboseLoggingEnabled: true,
  );
}
