import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';

Future<void> main(List<String> arguments) => ImpaktfullCli().run(
      (cli) => cli.appCenterPlugin.uploadToAppCenter(
        appName: '',
        ownerName: '',
        file: File('app.apk'),
        notifyListeners: false,
      ),
    );
