import 'package:impaktfull_cli/src/cli/command/config/command_config.dart';
import 'package:impaktfull_cli/src/cli/model/data/secret.dart';

class AppleCertificateInstallConfigData extends ConfigData {
  final Secret onePasswordUuid;
  final String keyChainName;

  const AppleCertificateInstallConfigData({
    required this.onePasswordUuid,
    required this.keyChainName,
  });
}
