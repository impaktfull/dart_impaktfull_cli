import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:impaktfull_cli/src/integrations/android/android_command.dart';
import 'package:impaktfull_cli/src/integrations/apple/apple_command.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/ci_cd_command.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/test_coverage_command.dart';
import 'package:test/test.dart';
import '../../tool/generate_docs.dart';

void main() {
  late DocsGenerator generator;

  setUp(() => generator = DocsGenerator());

  group('buildOptionsTable', () {
    test('generates header and rows for command with options', () {
      final root = AndroidRootCommand(processRunner: const CliProcessRunner());
      final cmd = root.subcommands['create_keystore']!;
      final table = generator.buildOptionsTable(cmd);

      expect(table,
          contains('| Option | Description | Required | Default | Allowed |'));
      expect(table, contains('`--fullName`'));
      expect(table, contains('Your full name'));
      expect(table, contains('| Yes |'));
      expect(table, contains('`--configName`'));
      expect(table, contains('debug, release'));
    });

    test('returns placeholder for command with no options', () {
      final root = CiCdRootCommand(processRunner: const CliProcessRunner());
      final cmd = root.subcommands['setup']!;
      final table = generator.buildOptionsTable(cmd);

      expect(table, equals('_No options._\n'));
    });

    test('formats boolean flags with --[no-] prefix', () {
      final root =
          TestCoverageRootCommand(processRunner: const CliProcessRunner());
      final cmd = root.subcommands['dart']!;
      final table = generator.buildOptionsTable(cmd);

      expect(table, contains('`--[no-]runTests`'));
      expect(table, contains('`--[no-]convertToLcov`'));
      expect(table, contains('`--[no-]overrideLcovFile`'));
    });

    test('excludes the built-in --help option', () {
      final root = AndroidRootCommand(processRunner: const CliProcessRunner());
      final cmd = root.subcommands['create_keystore']!;
      final table = generator.buildOptionsTable(cmd);

      expect(table, isNot(contains('`--help`')));
    });
  });

  group('buildCommandPage', () {
    test('generates valid MDX frontmatter with command name as title', () {
      final root = AndroidRootCommand(processRunner: const CliProcessRunner());
      final page = generator.buildCommandPage(root);

      expect(page, startsWith('---\ntitle: android\n---\n'));
    });

    test('includes root command description', () {
      final root = AndroidRootCommand(processRunner: const CliProcessRunner());
      final page = generator.buildCommandPage(root);

      expect(page, contains('Commands for Android integrations.'));
    });

    test('includes subcommand section heading', () {
      final root = AndroidRootCommand(processRunner: const CliProcessRunner());
      final page = generator.buildCommandPage(root);

      expect(page, contains('## create_keystore'));
    });

    test('includes correct usage line', () {
      final root = AndroidRootCommand(processRunner: const CliProcessRunner());
      final page = generator.buildCommandPage(root);

      expect(
        page,
        contains('dart run impaktfull_cli android create_keystore [options]'),
      );
    });

    test(
        'handles deeply nested subcommands (apple provisioning_profile install)',
        () {
      final root = AppleRootCommand(processRunner: const CliProcessRunner());
      final page = generator.buildCommandPage(root);

      expect(page, contains('## provisioning_profile install'));
      expect(
        page,
        contains(
          'dart run impaktfull_cli apple provisioning_profile install [options]',
        ),
      );
    });

    test('generates sections for all leaf subcommands', () {
      final root = CiCdRootCommand(processRunner: const CliProcessRunner());
      final page = generator.buildCommandPage(root);

      expect(page, contains('## report_status'));
      expect(page, contains('## setup'));
    });
  });
}
