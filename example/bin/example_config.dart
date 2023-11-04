import 'package:impaktfull_cli/impaktfull_cli.dart';

class ExampleConfig {
  static const String onePasswordUuid = 'your-1password-uuid';
  static const String keyChainName = 'MyKeyChain';
  static final Secret globalKeyChainPassword =
      CliInputReader.readKeyChainPassword();
}
