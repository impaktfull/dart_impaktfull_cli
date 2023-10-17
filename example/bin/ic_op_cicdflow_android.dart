import 'package:impaktfull_cli/impaktfull_cli.dart';

Future<void> main(List<String> arguments) async {
  await runImpaktfullCli(
    () => CiCdFlow().buildAndroid(),
    isVerboseLoggingEnabled: true,
  );
}
