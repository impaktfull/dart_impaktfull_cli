import 'package:impaktfull_cli/impaktfull_cli.dart';

import 'example_config.dart';

Future<void> main(List<String> arguments) async {
  await runImpaktfullCli(
    () async {
      final processRunner = CliProcessRunner();
      final onePasswordPlugin = OnePasswordPlugin(processRunner: processRunner);
      final keyChainPlugin = MacOsKeyChainPlugin(processRunner: processRunner);

      final keyChainName = ExampleConfig.keyChainName;
      final opUuid = ExampleConfig.onePasswordUuid;
      final globalKeyChainPasswordSecret = ExampleConfig.globalKeyChainPassword;
      ImpaktfullCliEnvironment.requiresInstalledTools([CliTool.onePasswordCli]);

      final certFile = await onePasswordPlugin.downloadDistributionCertificate(
          opUuid: opUuid);
      final certPassword =
          await onePasswordPlugin.getCertificatePassword(opUuid: opUuid);

      await keyChainPlugin.createKeyChain(
          keyChainName, globalKeyChainPasswordSecret);
      await keyChainPlugin.unlockKeyChain(
          keyChainName, globalKeyChainPasswordSecret);
      await keyChainPlugin.addCertificateToKeyChain(
          keyChainName, certFile, certPassword);

      CliLogger.debug('Execute build');
      await Future.delayed(const Duration(seconds: 2));

      await keyChainPlugin.removeKeyChain(keyChainName);
    },
    isVerboseLoggingEnabled: true,
  );
}
