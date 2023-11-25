import 'package:impaktfull_cli/src/core/util/logger/logger.dart';

class Secret {
  String value;

  Secret(this.value) {
    ImpaktfullCliLogger.saveSecret(value);
  }

  @override
  String toString() => value;
}
