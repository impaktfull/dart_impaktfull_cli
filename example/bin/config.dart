import 'package:impaktfull_cli/impaktfull_cli.dart';

class Config {
  static const String onePasswordUuid = 'your-1password-uuid';
  static const String keyChainName = 'MyKeyChain';
  static final Secret globalKeyChainPassword =
      ImpaktfullCliInputReader.readKeyChainPassword();
}
