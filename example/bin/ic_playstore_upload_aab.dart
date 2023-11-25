import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';

Future<void> main(List<String> arguments) async {
  await runImpaktfullCli(
    () async {
      final processRunner = CliProcessRunner();
      final testFlightPlugin = PlayStorePlugin(processRunner: processRunner);
      await testFlightPlugin.uploadToPlayStore(
        file: File('app.aab'),
      );
    },
    isVerboseLoggingEnabled: true,
  );
}
