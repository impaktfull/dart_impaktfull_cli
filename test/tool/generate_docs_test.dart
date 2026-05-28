import 'dart:io';

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
      expect(table, isNot(contains('[debug, release]')));
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

  group('extractEnvKeys', () {
    test('extracts private env key constants', () {
      const source = """
        static const _envKeyCiKeyChainPassword = 'CI_KEYCHAIN_PASSWORD';
        static const _envKeyAppleEmail = 'APPLE_EMAIL';
      """;
      final keys = generator.extractEnvKeys(source);
      expect(keys, containsAll(['CI_KEYCHAIN_PASSWORD', 'APPLE_EMAIL']));
    });

    test('extracts public env key constants', () {
      const source = """
        static const envKeyOnePasswordAccountToken = 'OP_SERVICE_ACCOUNT_TOKEN';
        static const envKeySlackSendMessageChannel = 'SLACK_SEND_MESSAGE_CHANNEL';
      """;
      final keys = generator.extractEnvKeys(source);
      expect(
          keys,
          containsAll(
              ['OP_SERVICE_ACCOUNT_TOKEN', 'SLACK_SEND_MESSAGE_CHANNEL']));
    });

    test('does not extract non-envKey constants', () {
      const source = """
        static const _optionJobName = 'jobName';
        static const _envKeyAppleEmail = 'APPLE_EMAIL';
      """;
      final keys = generator.extractEnvKeys(source);
      expect(keys, equals(['APPLE_EMAIL']));
      expect(keys, isNot(contains('jobName')));
    });

    test('extracts all 10 keys from the actual env vars file', () {
      final source = File(
        'lib/src/core/util/args/env/impaktfull_cli_environment_variables.dart',
      ).readAsStringSync();
      final keys = generator.extractEnvKeys(source);
      expect(keys.length, equals(10));
      expect(
        keys,
        containsAll([
          'CI_KEYCHAIN_PASSWORD',
          'APPCENTER_OWNER_NAME',
          'APPCENTER_API_TOKEN',
          'APPLE_EMAIL',
          'APPLE_APP_SPECIFIC_PASSWORD',
          'GOOGLE_SERVICE_ACCOUNT_JSON_RAW',
          'OP_SERVICE_ACCOUNT_TOKEN',
          'SLACK_BOT_TOKEN',
          'SLACK_SEND_MESSAGE_CHANNEL',
          'GITHUB_RUN_NUMBER',
        ]),
      );
    });
  });
}
