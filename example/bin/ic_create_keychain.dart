import 'package:impaktfull_cli/impaktfull_cli.dart';

import 'example_config.dart';

Future<void> main(List<String> arguments) =>
    ImpaktfullCli().runWithPlugin<MacOsKeyChainPlugin>(
      (plugin) async {
        final keyChainName = ExampleConfig.keyChainName;
        final globalKeyChainPasswordSecret =
            ExampleConfig.globalKeyChainPassword;

        await plugin.printKeyChainList();
        await plugin.createKeyChain(keyChainName, globalKeyChainPasswordSecret);
        await plugin.printKeyChainList();
        await plugin.unlockKeyChain(keyChainName, globalKeyChainPasswordSecret);

        ImpaktfullCliLogger.debug('Execute build');
        await Future.delayed(const Duration(seconds: 5));

        await plugin.printKeyChainList();
        await plugin.removeKeyChain(keyChainName);
        await plugin.printKeyChainList();
      },
    );
