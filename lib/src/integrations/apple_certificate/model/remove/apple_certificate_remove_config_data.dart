import 'package:impaktfull_cli/src/core/command/config/command_config.dart';

class AppleCertificateRemoveConfigData extends ConfigData {
  final String keyChainName;

  const AppleCertificateRemoveConfigData({
    required this.keyChainName,
  });
}
