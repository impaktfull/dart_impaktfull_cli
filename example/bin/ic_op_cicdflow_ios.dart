import 'package:impaktfull_cli/impaktfull_cli.dart';

Future<void> main(List<String> arguments) async {
  await runImpaktfullCli(
    () async => CiCdFlow().buildIos(),
    isVerboseLoggingEnabled: true,
  );
}
