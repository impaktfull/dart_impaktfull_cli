import 'dart:io';

import 'package:impaktfull_cli/src/core/model/data/environment/cli_tool.dart';
import 'package:impaktfull_cli/src/core/model/data/environment/installed_cli_tool.dart';
import 'package:impaktfull_cli/src/core/model/data/environment/operating_system.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/util/cli_tools/cli_tools_util.dart';
import 'package:impaktfull_cli/src/core/util/fvm/fvm_util.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';

class ImpaktfullCliEnvironment {
  static late ImpaktfullCliEnvironment _instance;

  final Directory workingDirectory;
  final bool isFvmProject;
  final List<InstalledCliTool> allCliTools;

  static ImpaktfullCliEnvironment get instance => _instance;

  List<InstalledCliTool> get installedCliTools =>
      CliToolsUtil.getInstalledCliTools(allCliTools);

  List<InstalledCliTool> get notInstalledCliTools =>
      CliToolsUtil.getNotInstalledCliTools(allCliTools);

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
      isFvmProject: await FvmUtil.isFvmProject(workingDir),
      allCliTools: await CliToolsUtil.checkInstalledTools(processRunner),
    );
    _printCurrentState();
  }

  static void requiresMacOs({required String reason}) {
    if (OperatingSystem.current != OperatingSystem.macOS) {
      throw ImpaktfullCliError('${reason.trim()} is only supported on macOS');
    }
  }

  static bool isInstalled(CliTool cliTool) =>
      CliToolsUtil.isInstalled(cliTool, _instance.allCliTools);

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
    ImpaktfullCliLogger.verbose(
        CliToolsUtil.getCliToolsLog(_instance.allCliTools));
    ImpaktfullCliLogger.verboseSeperator();
  }
}
