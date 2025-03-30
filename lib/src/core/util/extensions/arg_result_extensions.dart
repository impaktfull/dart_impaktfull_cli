import 'package:args/args.dart';
import 'package:impaktfull_cli/impaktfull_cli.dart';
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
    if (T == Secret) {
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

  T? getOptionOrAskInput<T>(String option, String question) {
    final value = getOption<T>(option);
    if (value != null) return value;
    if (T == bool) {
      return ImpaktfullCliLogger.askYesNoQuestion(question) as T;
    }
    final result = ImpaktfullCliLogger.askQuestion(question);
    if (result == null) return null;
    if (result.isEmpty) return null;
    return _parseResult(result);
  }

  T getRequiredOptionOrAskInput<T>(String option, String question) {
    T? result;
    String? suffix;
    do {
      result = getOptionOrAskInput<T>(
          option, suffix == null ? question : '$question: $suffix');
      suffix = '(Required)';
    } while (result == null);
    return result;
  }

  T getRequiredOption<T>(String option) {
    final value = getOption<T>(option);
    if (value == null) throw ArgumentError('$option not found in arguments');
    return value;
  }

  T getRequiredOptionOrEnvVariable<T>(String option, String envVariable) {
    final value = getOption<T>(option);
    if (value == null) {
      final secret =
          ImpaktfullCliEnvironmentVariables.getOptionalEnvVariableSecret(
              envVariable);
      if (secret == null) {
        throw ArgumentError(
            '$option not found in arguments or env variable `$envVariable`');
      }
      final result = _parseResult<T>(secret.value);
      if (result == null) {
        throw ArgumentError(
            '$option not found in arguments or env variable `$envVariable`');
      }
      return result;
    }
    return value;
  }

  T? _parseResult<T>(String result) {
    if (T == Secret) {
      if (result.isEmpty) return null;
      return Secret(result) as T;
    } else if (T == double) {
      return double.tryParse(result) as T;
    } else if (T == int) {
      return int.tryParse(result) as T;
    } else if (T is String) {
      if (result.isEmpty) return null;
    }
    return result as T?;
  }
}
