import 'package:impaktfull_cli/src/cli/plugin/impaktfull_plugin.dart';
import 'package:impaktfull_cli/src/cli/util/process/process_runner.dart';

abstract class ImpaktfullCliPlugin extends ImpaktfullPlugin {
  final ProcessRunner processRunner;

  const ImpaktfullCliPlugin({
    this.processRunner = const CliProcessRunner(),
  });
}
