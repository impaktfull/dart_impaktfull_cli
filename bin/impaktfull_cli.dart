import 'package:impaktfull_cli/src/cli/util/process/process_runner.dart';
import 'package:impaktfull_cli/src/impaktfull_cli.dart';

Future<void> main(List<String> arguments) async {
  final cli = ImpaktfullCli(processRunner: CliProcessRunner());
  await cli.run(arguments);
}
