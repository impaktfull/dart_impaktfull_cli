import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';

import 'example_config.dart';

Future<void> main(List<String> arguments) =>
    ImpaktfullCli().runWithPlugin<TestFlightPlugin>(
      (plugin) => plugin.uploadToTestflightWithEmailPassword(
        file: File('app.ipa'),
        userName: ExampleConfig.appleEmailAdress,
        appSpecificPassword: ExampleConfig.appleAppSpecificPassword,
      ),
    );
