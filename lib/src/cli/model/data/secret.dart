import 'package:impaktfull_cli/src/cli/util/logger/logger.dart';

class Secret {
  String value;

  Secret(this.value) {
    CliLogger.saveSecret(value);
  }

  @override
  String toString() => value;
}
