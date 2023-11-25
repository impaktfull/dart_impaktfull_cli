import 'package:impaktfull_cli/impaktfull_cli.dart';

Future<void> main(List<String> arguments) =>
    ImpaktfullCli().runWithPlugin<CiCdPlugin>(
      (plugin) => plugin.buildIos(),
    );
