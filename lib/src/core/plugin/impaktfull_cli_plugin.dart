import 'package:impaktfull_cli/src/core/plugin/impaktfull_plugin.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';

abstract class ImpaktfullCliPlugin extends ImpaktfullPlugin {
  final ProcessRunner processRunner;

  const ImpaktfullCliPlugin({
    required this.processRunner,
  });
}
