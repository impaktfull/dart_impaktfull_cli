import 'package:impaktfull_cli/impaktfull_cli.dart';

import 'example_config.dart';

Future<void> main(List<String> arguments) => ImpaktfullCli().run(
      (cli) async {
        final macOsKeyChainPlugin = cli.macOsKeyChainPlugin;
        final keyChainName = ExampleConfig.keyChainName;
        final globalKeyChainPasswordSecret = ExampleConfig.globalKeyChainPassword;

        await macOsKeyChainPlugin.printKeyChainList();
        await macOsKeyChainPlugin.createKeyChain(keyChainName, globalKeyChainPasswordSecret);
        await macOsKeyChainPlugin.printKeyChainList();
        await macOsKeyChainPlugin.unlockKeyChain(keyChainName, globalKeyChainPasswordSecret);

        ImpaktfullCliLogger.debug('Execute build');
        await Future.delayed(const Duration(seconds: 5));

        await macOsKeyChainPlugin.printKeyChainList();
        await macOsKeyChainPlugin.removeKeyChain(keyChainName);
        await macOsKeyChainPlugin.printKeyChainList();
      },
    );
