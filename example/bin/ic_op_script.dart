import 'package:impaktfull_cli/impaktfull_cli.dart';

import 'example_config.dart';

Future<void> main(List<String> arguments) => ImpaktfullCli().run(
      (cli) async {
        final onePasswordPlugin = cli.onePasswordPlugin;
        final keyChainPlugin = cli.macOsKeyChainPlugin;
        final keyChainName = ExampleConfig.keyChainName;
        final opUuid = ExampleConfig.onePasswordUuid;
        final globalKeyChainPasswordSecret = ExampleConfig.globalKeyChainPassword;
        ImpaktfullCliEnvironment.requiresInstalledTools([CliTool.onePasswordCli]);

        final certFile = await onePasswordPlugin.downloadDistributionCertificate(opUuid: opUuid);
        final certPassword = await onePasswordPlugin.getCertificatePassword(opUuid: opUuid);

        await keyChainPlugin.createKeyChain(keyChainName, globalKeyChainPasswordSecret);
        await keyChainPlugin.unlockKeyChain(keyChainName, globalKeyChainPasswordSecret);
        await keyChainPlugin.addCertificateToKeyChain(keyChainName, certFile, certPassword);

        ImpaktfullCliLogger.debug('Execute build');
        await Future.delayed(const Duration(seconds: 2));

        await keyChainPlugin.removeKeyChain(keyChainName);
      },
    );
