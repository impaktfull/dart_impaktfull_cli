import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';

Future<void> main(List<String> arguments) =>
    ImpaktfullCli().runWithPlugin<PlayStorePlugin>(
      (plugin) => plugin.uploadToPlayStore(
        file: File('app.aab'),
      ),
    );
