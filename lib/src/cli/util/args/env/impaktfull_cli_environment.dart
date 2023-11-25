import 'dart:io';

import 'package:impaktfull_cli/src/cli/model/data/environment/cli_tool.dart';
import 'package:impaktfull_cli/src/cli/model/data/environment/installed_cli_tool.dart';
import 'package:impaktfull_cli/src/cli/model/data/environment/operating_system.dart';
import 'package:impaktfull_cli/src/cli/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/cli/util/logger/logger.dart';
import 'package:impaktfull_cli/src/cli/util/process/process_runner.dart';
import 'package:path/path.dart';

class ImpaktfullCliEnvironment {
  static late ImpaktfullCliEnvironment _instance;

  final bool verboseLoggingEnabled;
  final Directory workingDir;
  final bool isFvmProject;
  final List<InstalledCliTool> allCliTools;

  static bool get useFvmForFlutterBuilds => _instance.isFvmProject;

  List<InstalledCliTool> get installedCliTools =>
      allCliTools.where((element) => element.isInstalled).toList();

  List<InstalledCliTool> get notInstalledCliTools =>
      allCliTools.where((element) => !element.isInstalled).toList();

  const ImpaktfullCliEnvironment._({
    required this.verboseLoggingEnabled,
    required this.workingDir,
    required this.isFvmProject,
    required this.allCliTools,
  });

  static Future<void> init({
    ProcessRunner processRunner = const CliProcessRunner(),
    bool isVerboseLoggingEnabled = false,
  }) async {
    CliLogger.init(isVerboseLoggingEnabled: isVerboseLoggingEnabled);
    final workingDir = Directory.current;
    _instance = ImpaktfullCliEnvironment._(
      verboseLoggingEnabled: isVerboseLoggingEnabled,
      workingDir: workingDir,
      isFvmProject: await _checkIfActiveProjectIsFvm(workingDir),
      allCliTools: await _checkInstalledTools(processRunner),
    );
    _printCurrentState();
  }

  static Future<bool> _checkIfActiveProjectIsFvm(Directory workingDir) async {
    final fvmConfigFile = File(join(workingDir.path, 'fvm', 'fvm_config.json'));
    return fvmConfigFile.exists();
  }

  static Future<List<InstalledCliTool>> _checkInstalledTools(
          ProcessRunner processRunner) async =>
      CliTool.values
          .where((element) => element.supportedOperatingSystems
              .contains(OperatingSystem.current))
          .map((cliTool) => _isToolInstalled(processRunner, cliTool))
          .wait;

  static Future<InstalledCliTool> _isToolInstalled(
      ProcessRunner processRunner, CliTool cliTool) async {
    final result =
        await processRunner.runProcess(['which', cliTool.commandName]);
    if (result.isEmpty) return InstalledCliTool.notInstalled(cliTool: cliTool);
    return InstalledCliTool.installed(
      cliTool: cliTool,
      path: result,
    );
  }

  static void requiresMacOs({required String reason}) {
    if (OperatingSystem.current != OperatingSystem.macOS) {
      throw ImpaktfullCliError('${reason.trim()} is only supported on macOS');
    }
  }

  static void requiresInstalledTools(List<CliTool> requiredTools) {
    final requiredToolsFound = <CliTool>[];
    final installedCliTools = _instance.installedCliTools.map((e) => e.cliTool);
    for (final requiredTool in requiredTools) {
      if (installedCliTools.contains(requiredTool)) {
        requiredToolsFound.add(requiredTool);
      }
    }
    if (requiredToolsFound.length != requiredTools.length) {
      final missingTools = requiredTools
          .where((element) => !requiredToolsFound.contains(element));
      throw ImpaktfullCliError(
          '${missingTools.map((e) => '${e.commandName} (${e.name})').join(', ')} are not installed, but required for the next step');
    }
  }

  static void _printCurrentState() {
    CliLogger.debugSeperator();
    CliLogger.debug('Operating system: ${OperatingSystem.current.name}');
    CliLogger.debug('Working Dir: `${_instance.workingDir.path}`');
    CliLogger.debug('Is fvm project: `${_instance.isFvmProject}`');
    if (_instance.installedCliTools.isNotEmpty) {
      CliLogger.debug('Installed Tools:');
      for (final clitool in _instance.installedCliTools) {
        CliLogger.debug('\t${clitool.cliTool.commandName} - ${clitool.path}');
      }
    }
    if (_instance.notInstalledCliTools.isNotEmpty) {
      CliLogger.debug('Not Installed Tools:');
      for (final notInstalledCliTool in _instance.notInstalledCliTools) {
        final cliTool = notInstalledCliTool.cliTool;
        var log = '\t${cliTool.commandName}';
        final installationInstructions =
            cliTool.installationInstructions[OperatingSystem.current];
        if (installationInstructions != null) {
          log += ' - Install instructions: $installationInstructions';
        }
        CliLogger.debug(log);
      }
    }
    CliLogger.debugSeperator();
  }
}
