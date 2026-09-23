import 'dart:convert';

import 'package:impaktfull_cli/src/core/model/data/environment/cli_tool.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment.dart';
import 'package:impaktfull_cli/src/core/util/fvm/fvm_util.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

/// The command that starts `flutter` or `dart` for the current project.
///
/// A project with an fvm config runs through `fvm`. When fvm is not installed,
/// which is common on GitHub-hosted runners that set up Flutter with
/// `subosito/flutter-action`, the `flutter` or `dart` on the PATH is used
/// instead, and the version that was used is logged and compared with the one
/// fvm pins.
class FlutterCommand {
  const FlutterCommand._();

  static Future<void>? _fallbackCheck;

  static Future<List<String>> flutter(ProcessRunner processRunner) =>
      _command(processRunner, CliTool.flutter);

  static Future<List<String>> dart(ProcessRunner processRunner) =>
      _command(processRunner, CliTool.dart);

  static Future<List<String>> _command(
    ProcessRunner processRunner,
    CliTool tool,
  ) async {
    final environment = ImpaktfullCliEnvironment.instance;
    if (!environment.isFvmProject) return [tool.commandName];
    if (ImpaktfullCliEnvironment.isInstalled(CliTool.fvm)) {
      return ['fvm', tool.commandName];
    }
    // Checked once per run, not for every command.
    await (_fallbackCheck ??= _logFallback(processRunner, tool));
    return [tool.commandName];
  }

  static Future<void> _logFallback(
    ProcessRunner processRunner,
    CliTool tool,
  ) async {
    final configFile = FvmUtil.findConfigFile(
      ImpaktfullCliEnvironment.instance.workingDirectory,
    );
    final configName = configFile == null ? 'fvm' : basename(configFile.path);
    final pinnedVersion = configFile == null
        ? null
        : FvmUtil.getFlutterVersion(configFile);
    final sb = StringBuffer(
      'fvm is not installed, so `${tool.commandName}` from the PATH is used '
      'instead of `fvm ${tool.commandName}`.',
    );
    if (tool == CliTool.flutter ||
        ImpaktfullCliEnvironment.isInstalled(CliTool.flutter)) {
      sb.write(
        await _describeFlutter(processRunner, configName, pinnedVersion),
      );
    } else {
      sb.write(await _describeDart(processRunner, configName, pinnedVersion));
    }
    ImpaktfullCliLogger.warning(sb.toString());
  }

  static Future<String> _describeFlutter(
    ProcessRunner processRunner,
    String configName,
    String? pinnedVersion,
  ) async {
    final FlutterVersion version;
    try {
      final output = await processRunner.runProcess(
        ['flutter', '--version', '--machine'],
      );
      version = FlutterVersion.parse(output);
    } catch (e) {
      ImpaktfullCliLogger.verbose('Failed to read the Flutter version: $e');
      return '\nThe Flutter version could not be determined, so it could not '
          'be compared with the one $configName pins'
          '${pinnedVersion == null ? '' : ' ($pinnedVersion)'}.';
    }
    final sb = StringBuffer('\nUsed: $version');
    if (pinnedVersion == null) {
      sb.write('\n$configName does not pin a Flutter version to compare with.');
      return sb.toString();
    }
    final matches = FvmUtil.matchesFlutterVersion(
      pinnedVersion,
      frameworkVersion: version.frameworkVersion,
      channel: version.channel,
      frameworkRevision: version.frameworkRevision,
    );
    if (matches) {
      sb.write('\n$configName pins `$pinnedVersion`: matches ✅');
    } else {
      sb.write(
        '\n$configName pins `$pinnedVersion`: does NOT match ❌. Install fvm, '
        'or set up Flutter `$pinnedVersion` before running impaktfull_cli.',
      );
    }
    return sb.toString();
  }

  static Future<String> _describeDart(
    ProcessRunner processRunner,
    String configName,
    String? pinnedVersion,
  ) async {
    var dartVersion = 'an unknown Dart version';
    try {
      dartVersion = await processRunner.runProcess(['dart', '--version']);
    } catch (e) {
      ImpaktfullCliLogger.verbose('Failed to read the Dart version: $e');
    }
    return '\nUsed: $dartVersion'
        '${pinnedVersion == null ? '' : '\n$configName pins Flutter `$pinnedVersion`; without Flutter installed, the Dart version cannot be compared with it.'}';
  }

  @visibleForTesting
  static void reset() => _fallbackCheck = null;
}

/// The parts of `flutter --version --machine` that identify an SDK.
class FlutterVersion {
  final String frameworkVersion;
  final String channel;
  final String frameworkRevision;
  final String? flutterRoot;

  const FlutterVersion({
    required this.frameworkVersion,
    required this.channel,
    required this.frameworkRevision,
    this.flutterRoot,
  });

  /// Parses the output of `flutter --version --machine`, which can be preceded
  /// by other output (like a first-run welcome message).
  factory FlutterVersion.parse(String output) {
    final start = output.indexOf('{');
    final end = output.lastIndexOf('}');
    if (start == -1 || end < start) {
      throw FormatException('No JSON found', output);
    }
    final json = jsonDecode(output.substring(start, end + 1));
    if (json is! Map<String, dynamic>) {
      throw FormatException('Not a JSON object', output);
    }
    final frameworkVersion = json['frameworkVersion'];
    if (frameworkVersion is! String) {
      throw FormatException('No frameworkVersion', output);
    }
    return FlutterVersion(
      frameworkVersion: frameworkVersion,
      channel: json['channel'] as String? ?? 'unknown',
      frameworkRevision: json['frameworkRevision'] as String? ?? '',
      flutterRoot: json['flutterRoot'] as String?,
    );
  }

  @override
  String toString() =>
      'Flutter $frameworkVersion ($channel)${flutterRoot == null ? '' : ' at $flutterRoot'}';
}
