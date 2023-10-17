import 'package:args/args.dart';
import 'package:impaktfull_cli/src/model/data/secret.dart';
import 'package:impaktfull_cli/src/util/extensions/arg_parser_extensions.dart';

extension ArgsExtension on ArgResults {
  bool isVerboseLoggingEnabled() => getFlag(ArgsParserExtension.verboseFlag);

  bool getFlag(String flag) => getOption<bool>(flag) == true;

  T? getOption<T>(String option) {
    if (T is Secret) {
      final value = this[option] as String?;
      if (value == null) {
        return null;
      } else {
        return Secret(value) as T;
      }
    }
    final value = this[option] as T?;
    if (value == null) return null;
    return value;
  }

  T getRequiredOption<T>(String option) {
    final value = getOption<T>(option);
    if (value == null) throw ArgumentError('$option not found in arguments');
    return value;
  }
}
