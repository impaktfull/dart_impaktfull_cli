import 'package:impaktfull_cli/src/cli/command/config/command_config.dart';

class AppleCertificateRemoveConfigData extends ConfigData {
  final String keyChainName;

  const AppleCertificateRemoveConfigData({
    required this.keyChainName,
  });
}
