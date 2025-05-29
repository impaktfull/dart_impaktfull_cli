import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/core/model/data/environment/installed_cli_tool.dart';
import 'package:impaktfull_cli/src/core/model/data/environment/operating_system.dart';

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

  static String getCliToolsLog(List<InstalledCliTool> allCliTools) {
    final sb = StringBuffer();
    final installedCliTools = getInstalledCliTools(allCliTools);
    final notInstalledCliTools = getNotInstalledCliTools(allCliTools);
    sb.writeln('Installed Tools:');
    for (final cliTool in installedCliTools) {
      sb.writeln('\t${cliTool.cliTool.commandName} - ${cliTool.path}');
    }
    sb.writeln('Not Installed Tools:');
    for (final cliTool in installedCliTools) {
      sb.writeln('\t${cliTool.cliTool.commandName} - ${cliTool.path}');
    }
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
