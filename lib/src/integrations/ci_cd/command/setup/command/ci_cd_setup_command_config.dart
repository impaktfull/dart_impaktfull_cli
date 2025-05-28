import 'package:args/args.dart';
import 'package:impaktfull_cli/src/core/command/config/command_config.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/command/setup/command/model/ci_cd_setup_config_data.dart';

class CiCdSetupCommandConfig extends CommandConfig<CiCdSetupConfigData> {
  const CiCdSetupCommandConfig();

  @override
  void addConfig(ArgParser argParser) {}

  @override
  CiCdSetupConfigData parseResult(ArgResults? argResults) => CiCdSetupConfigData();
}
