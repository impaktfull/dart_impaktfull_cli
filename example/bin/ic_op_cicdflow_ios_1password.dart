import 'package:impaktfull_cli/impaktfull_cli.dart';

import 'example_config.dart';

Future<void> main(List<String> arguments) async {
  await runImpaktfullCli(
    () async {
      final processRunner = CliProcessRunner();
      final ciCdFlow = CiCdFlow(
        onePasswordPlugin: OnePasswordPlugin(processRunner: processRunner),
        macOsKeyChainPlugin: MacOsKeyChainPlugin(processRunner: processRunner),
        flutterBuildPlugin: FlutterBuildPlugin(processRunner: processRunner),
        appCenterPlugin: AppCenterPlugin(),
      );
      await ciCdFlow.startBuildWithCertificateAndPasswordFromOnePassword(
        opUuid: ExampleConfig.onePasswordUuid,
        keyChainName: ExampleConfig.keyChainName,
        globalKeyChainPassword: ExampleConfig.globalKeyChainPassword,
        onStartBuild: () => ciCdFlow.buildIos(),
      );
    },
    isVerboseLoggingEnabled: true,
  );
}
