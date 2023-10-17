import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';

Future<void> main(List<String> arguments) async {
  await runImpaktfullCli(
    () async {
      final appCenterPlugin = AppCenterPlugin();
      await appCenterPlugin.uploadToAppCenter(
        appName: '',
        ownerName: '',
        file: File('app.apk'),
        notifyListeners: false,
      );
    },
    isVerboseLoggingEnabled: true,
  );
}
