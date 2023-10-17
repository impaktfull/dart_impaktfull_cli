import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/model/data/environment/installed_cli_tool.dart';
import 'package:impaktfull_cli/src/model/data/environment/operating_system.dart';
import 'package:impaktfull_cli/src/util/process/process_runner.dart';
import 'package:path/path.dart';

class ImpaktfullCliEnvironment {
  static late ImpaktfullCliEnvironment _instance;
  final bool verboseLoggingEnabled;
  final OperatingSystem operatingSystem;
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
    required this.operatingSystem,
    required this.workingDir,
    required this.isFvmProject,
    required this.allCliTools,
  });

  static Future<void> init({
    ProcessRunner processRunner = const CliProcessRunner(),
    bool isVerboseLoggingEnabled = false,
  }) async {
    ImpaktfullCliLogger.init(isVerboseLoggingEnabled: isVerboseLoggingEnabled);
    final workingDir = Directory.current;
    final operatingSystem = _getOperatingSystem();
    _instance = ImpaktfullCliEnvironment._(
      verboseLoggingEnabled: isVerboseLoggingEnabled,
      operatingSystem: operatingSystem,
      workingDir: workingDir,
      isFvmProject: await _checkIfActiveProjectIsFvm(workingDir),
      allCliTools: await _checkInstalledTools(processRunner, operatingSystem),
    );
    _printCurrentState();
  }

  static Future<bool> _checkIfActiveProjectIsFvm(Directory workingDir) async {
    final fvmConfigFile = File(join(workingDir.path, 'fvm', 'fvm_config.json'));
    return fvmConfigFile.exists();
  }

  static Future<List<InstalledCliTool>> _checkInstalledTools(
          ProcessRunner processRunner, OperatingSystem operatingSystem) async =>
      CliTool.values
          .where((element) =>
              element.supportedOperatingSystems.contains(operatingSystem))
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
    if (_instance.operatingSystem != OperatingSystem.macOS) {
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

  static OperatingSystem _getOperatingSystem() {
    if (Platform.isMacOS) {
      return OperatingSystem.macOS;
    }
    throw ImpaktfullCliError('Current operating system is not yet supported');
  }

  static void _printCurrentState() {
    ImpaktfullCliLogger.debugSeperator();
    ImpaktfullCliLogger.debug(
        'Operating system: ${_instance.operatingSystem.name}');
    ImpaktfullCliLogger.debug('Working Dir: `${_instance.workingDir.path}`');
    ImpaktfullCliLogger.debug('Is fvm project: `${_instance.isFvmProject}`');
    if (_instance.installedCliTools.isNotEmpty) {
      ImpaktfullCliLogger.debug(
          'Installed Tools:\n${_instance.installedCliTools.map((e) => '\t${e.cliTool.commandName} - ${e.path}').join('')}');
    }
    if (_instance.notInstalledCliTools.isNotEmpty) {
      ImpaktfullCliLogger.debug(
          'Not Installed Tools:\n${_instance.notInstalledCliTools.map((e) => '\t${e.cliTool.commandName} - ${e.cliTool.name}').join('\n')}');
    }
    ImpaktfullCliLogger.debugSeperator();
  }
}
