import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:impaktfull_cli/src/integrations/android/android_command.dart';
import 'package:impaktfull_cli/src/integrations/apple/apple_command.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/ci_cd_command.dart';
import 'package:impaktfull_cli/src/integrations/open_souce/open_source_command.dart';
import 'package:impaktfull_cli/src/integrations/slack/slack_command.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/test_coverage_command.dart';

void main() => DocsGenerator().generate();

class DocsGenerator {
  static const _docsDir = 'docs';
  static const _commandsDir = '$_docsDir/commands';
  static const _envVarsFile =
      'lib/src/core/util/args/env/impaktfull_cli_environment_variables.dart';

  void generate() {
    final commands = [
      AndroidRootCommand(processRunner: const CliProcessRunner()),
      AppleRootCommand(processRunner: const CliProcessRunner()),
      CiCdRootCommand(processRunner: const CliProcessRunner()),
      OpenSourceRootCommand(processRunner: const CliProcessRunner()),
      SlackRootCommand(processRunner: const CliProcessRunner()),
      TestCoverageRootCommand(processRunner: const CliProcessRunner()),
    ];

    Directory(_commandsDir).createSync(recursive: true);

    for (final cmd in commands) {
      final content = buildCommandPage(cmd);
      final file = File('$_commandsDir/${cmd.name}.mdx');
      file.writeAsStringSync(content);
      print('Generated ${file.path}');
    }

    final envSource = File(_envVarsFile).readAsStringSync();
    final envKeys = extractEnvKeys(envSource);
    final configFile = File('$_docsDir/configuration.mdx');
    configFile.writeAsStringSync(buildConfigurationPage(envKeys));
    print('Generated ${configFile.path}');
  }

  String buildCommandPage(Command<void> rootCmd) {
    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.writeln('title: ${rootCmd.name}');
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln(rootCmd.description);
    buffer.writeln();
    _appendLeafSections(buffer, rootCmd.name, '', rootCmd);
    return buffer.toString();
  }

  void _appendLeafSections(
    StringBuffer buffer,
    String rootName,
    String sectionPrefix,
    Command<void> cmd,
  ) {
    for (final sub in cmd.subcommands.values) {
      final sectionName =
          sectionPrefix.isEmpty ? sub.name : '$sectionPrefix ${sub.name}';
      if (sub.subcommands.isEmpty) {
        buffer.write(_buildLeafSection(rootName, sectionName, sub));
      } else {
        _appendLeafSections(buffer, rootName, sectionName, sub);
      }
    }
  }

  String _buildLeafSection(
    String rootName,
    String sectionName,
    Command<void> cmd,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('## $sectionName');
    buffer.writeln();
    buffer.writeln(cmd.description);
    buffer.writeln();
    buffer.writeln('**Usage:**');
    buffer.writeln();
    buffer.writeln('```bash');
    buffer.writeln('dart run impaktfull_cli $rootName $sectionName [options]');
    buffer.writeln('```');
    buffer.writeln();
    buffer.write(buildOptionsTable(cmd));
    buffer.writeln();
    return buffer.toString();
  }

  String buildOptionsTable(Command<void> cmd) {
    final options =
        cmd.argParser.options.values.where((o) => o.name != 'help').toList();

    if (options.isEmpty) return '_No options._\n';

    final buffer = StringBuffer();
    buffer.writeln('| Option | Description | Required | Default | Allowed |');
    buffer.writeln('|---|---|---|---|---|');
    for (final option in options) {
      final name = option.isFlag ? '--[no-]${option.name}' : '--${option.name}';
      final desc = option.help ?? '';
      final required = option.mandatory ? 'Yes' : 'No';
      final def = switch (option.defaultsTo) {
        List<String> list => list.join(', '),
        final other => other?.toString() ?? '',
      };
      final allowed = option.allowed?.join(', ') ?? '';
      buffer.writeln('| `$name` | $desc | $required | $def | $allowed |');
    }
    return buffer.toString();
  }

  List<String> extractEnvKeys(String source) {
    final regex = RegExp(
        r"static const (?:String )?_?envKey\w+\s*=\s*'([^']+)'",
        multiLine: true);
    return regex.allMatches(source).map((m) => m.group(1)!).toList();
  }

  String buildConfigurationPage(List<String> envKeys) {
    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.writeln('title: Configuration');
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln(
      'impaktfull CLI reads these environment variables at runtime. '
      'Set them in your CI/CD environment or local shell.',
    );
    buffer.writeln();
    buffer.writeln('| Variable | Description |');
    buffer.writeln('|---|---|');
    for (final key in envKeys) {
      buffer.writeln('| `$key` | |');
    }
    return buffer.toString();
  }
}
