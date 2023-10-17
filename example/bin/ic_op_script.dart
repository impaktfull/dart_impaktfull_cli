import 'package:impaktfull_cli/impaktfull_cli.dart';

import 'config.dart';

Future<void> main(List<String> arguments) async {
  await runImpaktfullCli(
    () async {
      final onePasswordPlugin = OnePasswordPlugin();
      final keyChainPlugin = MacOsKeyChainPlugin();

      final keyChainName = Config.keyChainName;
      final opUuid = Config.onePasswordUuid;
      final globalKeyChainPasswordSecret = Config.globalKeyChainPassword;
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

      ImpaktfullCliLogger.debug('Execute build');
      await Future.delayed(const Duration(seconds: 2));

      await keyChainPlugin.removeKeyChain(keyChainName);
    },
    isVerboseLoggingEnabled: true,
  );
}
