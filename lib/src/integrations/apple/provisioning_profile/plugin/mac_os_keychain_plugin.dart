import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';

class AppleProvisioningProfilePlugin extends ImpaktfullCliPlugin {
  const AppleProvisioningProfilePlugin({
    super.processRunner = const CliProcessRunner(),
  });
}
