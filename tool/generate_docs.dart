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
    throw UnimplementedError();
  }

  String buildCommandPage(Command rootCmd) {
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
    Command cmd,
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
    Command cmd,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('## $sectionName');
    buffer.writeln();
    buffer.writeln(cmd.description);
    buffer.writeln();
    buffer.writeln('**Usage:**');
    buffer.writeln();
    buffer.writeln('```bash');
    buffer.writeln(
        'dart run impaktfull_cli $rootName $sectionName [options]');
    buffer.writeln('```');
    buffer.writeln();
    buffer.write(buildOptionsTable(cmd));
    buffer.writeln();
    return buffer.toString();
  }

  String buildOptionsTable(Command cmd) {
    final options =
        cmd.argParser.options.values.where((o) => o.name != 'help').toList();

    if (options.isEmpty) return '_No options._\n';

    final buffer = StringBuffer();
    buffer.writeln('| Option | Description | Required | Default | Allowed |');
    buffer.writeln('|---|---|---|---|---|');
    for (final option in options) {
      final name =
          option.isFlag ? '--[no-]${option.name}' : '--${option.name}';
      final desc = option.help ?? '';
      final required = option.mandatory ? 'Yes' : 'No';
      final def = option.defaultsTo?.toString() ?? '';
      final allowed = option.allowed?.join(', ') ?? '';
      buffer.writeln('| `$name` | $desc | $required | $def | $allowed |');
    }
    return buffer.toString();
  }

  List<String> extractEnvKeys(String source) {
    throw UnimplementedError();
  }

  String buildConfigurationPage(List<String> envKeys) {
    throw UnimplementedError();
  }
}
