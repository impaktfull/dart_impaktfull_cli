import 'package:impaktfull_cli/impaktfull_cli.dart';

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
      await ciCdFlow.buildAndroid();
    },
    isVerboseLoggingEnabled: true,
  );
}
