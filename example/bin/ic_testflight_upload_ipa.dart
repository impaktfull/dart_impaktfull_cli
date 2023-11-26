import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';

import 'example_config.dart';

Future<void> main(List<String> arguments) => ImpaktfullCli().run(
      (plugin) => plugin.testflightPlugin.uploadToTestflightWithEmailPassword(
        file: File('app.ipa'),
        userName: ExampleConfig.appleEmailAdress,
        appSpecificPassword: ExampleConfig.appleAppSpecificPassword,
      ),
    );
