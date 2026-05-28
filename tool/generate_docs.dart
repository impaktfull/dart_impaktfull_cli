import 'package:args/command_runner.dart';

void main() => DocsGenerator().generate();

class DocsGenerator {
  void generate() {
    throw UnimplementedError();
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
      final def = option.defaultsTo?.toString() ?? '';
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
    throw UnimplementedError();
  }
}
