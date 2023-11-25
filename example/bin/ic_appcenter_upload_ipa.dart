import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';

Future<void> main(List<String> arguments) =>
    ImpaktfullCli().runWithPlugin<AppCenterPlugin>(
      (plugin) async {
        await plugin.uploadToAppCenter(
          appName: '',
          ownerName: '',
          file: File('app.ipa'),
          notifyListeners: false,
        );
      },
    );
