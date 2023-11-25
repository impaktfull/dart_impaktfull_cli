import 'package:args/args.dart';
import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_parser_extensions.dart';

extension ArgResultExtensions on ArgResults? {
  bool isVerboseLoggingEnabled() => getFlag(ArgsParserExtension.verboseFlag);

  bool getFlag(String flag) => getOption<bool>(flag) == true;

  bool hasOption(String name, String value) {
    final option = this?[name];
    if (option is String) {
      return option == value;
    } else if (option is List) {
      return option.contains(value);
    }
    return false;
  }

  T? getOption<T>(String option) {
    if (T is Secret) {
      final value = this?[option] as String?;
      if (value == null) {
        return null;
      } else {
        return Secret(value) as T;
      }
    }
    final value = this?[option] as T?;
    if (value == null) return null;
    return value;
  }

  T getRequiredOption<T>(String option) {
    final value = getOption<T>(option);
    if (value == null) throw ArgumentError('$option not found in arguments');
    return value;
  }
}
