import 'dart:io';

import 'package:impaktfull_cli/src/core/model/data/environment/cli_tool.dart';
import 'package:impaktfull_cli/src/core/model/data/environment/installed_cli_tool.dart';
import 'package:impaktfull_cli/src/core/model/data/environment/operating_system.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:path/path.dart';

class ImpaktfullCliEnvironment {
  static late ImpaktfullCliEnvironment _instance;

  final Directory workingDirectory;
  final bool isFvmProject;
  final List<InstalledCliTool> allCliTools;

  static ImpaktfullCliEnvironment get instance => _instance;

  List<InstalledCliTool> get installedCliTools =>
      allCliTools.where((element) => element.isInstalled).toList();

  List<InstalledCliTool> get notInstalledCliTools =>
      allCliTools.where((element) => !element.isInstalled).toList();

  const ImpaktfullCliEnvironment._({
    required this.workingDirectory,
    required this.isFvmProject,
    required this.allCliTools,
  });

  static Future<void> init({
    ProcessRunner processRunner = const CliProcessRunner(),
  }) async {
    final workingDir = Directory.current;
    _instance = ImpaktfullCliEnvironment._(
      workingDirectory: workingDir,
      isFvmProject: await _checkIfActiveProjectIsFvm(workingDir),
      allCliTools: await _checkInstalledTools(processRunner),
    );
    _printCurrentState();
  }

  static Future<bool> _checkIfActiveProjectIsFvm(Directory workingDir) async {
    final fvmrcFile = File(join(workingDir.path, '.fvmrc'));
    if (fvmrcFile.existsSync()) {
      return true;
    }
    // fvm_config.json is the old config file
    final fvmConfigFile = File(join(workingDir.path, 'fvm', 'fvm_config.json'));
    return fvmConfigFile.existsSync();
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
    try {
      final result =
          await processRunner.runProcess(['which', cliTool.commandName]);
      if (result.isEmpty) {
        return InstalledCliTool.notInstalled(
          cliTool: cliTool,
        );
      }
      return InstalledCliTool.installed(
        cliTool: cliTool,
        path: result,
      );
    } catch (e) {
      ImpaktfullCliLogger.log(
          'Failed to check if ${cliTool.commandName} is installed');
      return InstalledCliTool.notInstalled(
        cliTool: cliTool,
      );
    }
  }

  static void requiresMacOs({required String reason}) {
    if (OperatingSystem.current != OperatingSystem.macOS) {
      throw ImpaktfullCliError('${reason.trim()} is only supported on macOS');
    }
  }

  static bool isInstalled(CliTool cliTool) =>
      _instance.allCliTools.any((element) => element.cliTool == cliTool);

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
    ImpaktfullCliLogger.verboseSeperator();
    ImpaktfullCliLogger.verbose(
        'Operating system: ${OperatingSystem.current.name}');
    ImpaktfullCliLogger.verbose(
        'Working Dir: `${_instance.workingDirectory.path}`');
    ImpaktfullCliLogger.verbose('Is fvm project: `${_instance.isFvmProject}`');
    if (_instance.installedCliTools.isNotEmpty) {
      ImpaktfullCliLogger.verbose('Installed Tools:');
      for (final clitool in _instance.installedCliTools) {
        ImpaktfullCliLogger.verbose(
            '\t${clitool.cliTool.commandName} - ${clitool.path}');
      }
    }
    if (_instance.notInstalledCliTools.isNotEmpty) {
      ImpaktfullCliLogger.verbose('Not Installed Tools:');
      for (final notInstalledCliTool in _instance.notInstalledCliTools) {
        final cliTool = notInstalledCliTool.cliTool;
        var log = '\t${cliTool.commandName}';
        final installationInstructions =
            cliTool.installationInstructions[OperatingSystem.current];
        if (installationInstructions != null) {
          log += ' - Install instructions: $installationInstructions';
        }
        ImpaktfullCliLogger.verbose(log);
      }
    }
    ImpaktfullCliLogger.verboseSeperator();
  }
}
