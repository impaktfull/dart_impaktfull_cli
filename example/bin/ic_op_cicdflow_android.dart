import 'package:impaktfull_cli/impaktfull_cli.dart';

Future<void> main(List<String> arguments) => ImpaktfullCli().run(
      (cli) => cli.ciCdPlugin.buildAndroid(),
    );
