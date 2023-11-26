import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';

Future<void> main(List<String> arguments) => ImpaktfullCli().run(
      (plugin) => plugin.playStorePlugin.uploadToPlayStore(
        file: File('app.aab'),
      ),
    );
