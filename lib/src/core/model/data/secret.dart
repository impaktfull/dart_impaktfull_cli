import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:uuid/uuid.dart';

class Secret {
  String value;

  Secret(this.value) {
    ImpaktfullCliLogger.saveSecret(value);
  }

  static Secret random() => Secret(Uuid().v4());

  @override
  String toString() => value;
}
