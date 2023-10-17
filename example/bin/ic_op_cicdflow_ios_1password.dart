import 'package:impaktfull_cli/impaktfull_cli.dart';

import 'config.dart';

Future<void> main(List<String> arguments) async {
  await runImpaktfullCli(
    () async {
      final ciCdFlow = CiCdFlow();
      await ciCdFlow.startBuildWithCertificateAndPasswordFromOnePassword(
        opUuid: Config.onePasswordUuid,
        keyChainName: Config.keyChainName,
        globalKeyChainPassword: Config.globalKeyChainPassword,
        onStartBuild: () => ciCdFlow.buildIos(),
      );
    },
    isVerboseLoggingEnabled: true,
  );
}
