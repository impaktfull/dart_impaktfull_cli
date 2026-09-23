import 'dart:convert';

import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/model/data/environment/installed_cli_tool.dart';
import 'package:impaktfull_cli/src/core/model/data/environment/operating_system.dart';
import 'package:meta/meta.dart';

class CliToolsUtil {
  const CliToolsUtil._();

  static List<InstalledCliTool> getInstalledCliTools(
          List<InstalledCliTool> allCliTools) =>
      allCliTools.where((element) => element.isInstalled).toList();

  static List<InstalledCliTool> getNotInstalledCliTools(
          List<InstalledCliTool> allCliTools) =>
      allCliTools.where((element) => !element.isInstalled).toList();

  static bool isInstalled(
    CliTool cliTool,
    List<InstalledCliTool> allCliTools,
  ) =>
      allCliTools.any((element) {
        if (element.cliTool != cliTool) return false;
        return element.isInstalled;
      });

  static Future<List<InstalledCliTool>> checkInstalledTools(
          ProcessRunner processRunner) async =>
      CliTool.values
          .where((element) => element.supportedOperatingSystems
              .contains(OperatingSystem.current))
          .map((cliTool) => _isToolInstalled(processRunner, cliTool))
          .wait;

  static Future<InstalledCliTool> _isToolInstalled(
    ProcessRunner processRunner,
    CliTool cliTool,
  ) async {
    try {
      final result = await processRunner.runProcess([
        // Windows has no `which`.
        OperatingSystem.current == OperatingSystem.windows ? 'where' : 'which',
        cliTool.commandName,
      ]);
      final path = parseToolPath(result);
      if (path == null) {
        return InstalledCliTool.notInstalled(
          cliTool: cliTool,
        );
      }
      return InstalledCliTool.installed(
        cliTool: cliTool,
        path: path,
      );
    } catch (e) {
      ImpaktfullCliLogger.verbose(
          'Failed to check if ${cliTool.commandName} is installed');
      return InstalledCliTool.notInstalled(
        cliTool: cliTool,
      );
    }
  }

  /// The first path in the output of `which` or `where`. `where` lists every
  /// match on the PATH, one per line (`flutter` and `flutter.bat`).
  @visibleForTesting
  static String? parseToolPath(String output) {
    for (final line in const LineSplitter().convert(output)) {
      final path = line.trim();
      if (path.isNotEmpty) return path;
    }
    return null;
  }

  static String getCliToolsLog(List<InstalledCliTool> allCliTools) {
    final sb = StringBuffer();
    final installedCliTools = getInstalledCliTools(allCliTools);
    final notInstalledCliTools = getNotInstalledCliTools(allCliTools);
    if (installedCliTools.isNotEmpty) {
      sb.writeln('Installed Tools:');
      for (final clitool in installedCliTools) {
        sb.writeln('\t${clitool.cliTool.commandName} - ${clitool.path}');
      }
    }
    if (notInstalledCliTools.isNotEmpty) {
      sb.writeln('Not Installed Tools:');
      for (final notInstalledCliTool in notInstalledCliTools) {
        final cliTool = notInstalledCliTool.cliTool;
        final cliToolSb = StringBuffer('\t${cliTool.commandName}');
        final installationInstructions =
            cliTool.installationInstructions[OperatingSystem.current];
        if (installationInstructions != null) {
          cliToolSb.write(' - Install instructions: $installationInstructions');
        }
        sb.writeln(cliToolSb.toString());
      }
    }
    return sb.toString();
  }
}
