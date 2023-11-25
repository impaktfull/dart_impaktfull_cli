import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_plugin.dart';
import 'package:impaktfull_cli/src/integrations/appcenter/plugin/appcenter_plugin.dart';
import 'package:impaktfull_cli/src/integrations/apple_certificate/command/apple_certificate_root_command.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_parser_extensions.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:impaktfull_cli/src/core/util/runner/runner.dart';
import 'package:impaktfull_cli/src/integrations/apple_certificate/plugin/mac_os_keychain_plugin.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/plugin/ci_cd_plugin.dart';
import 'package:impaktfull_cli/src/integrations/flutter/build/plugin/flutter_build_plugin.dart';
import 'package:impaktfull_cli/src/integrations/one_password/plugin/one_password_plugin.dart';
import 'package:impaktfull_cli/src/integrations/playstore/plugin/playstore_plugin.dart';
import 'package:impaktfull_cli/src/integrations/testflight/plugin/testflight_plugin.dart';

typedef ImpaktfullCliRunner = Future<void> Function(ImpaktfullCli cli);
typedef ImpaktfullCliSinglePluginRunner<T extends ImpaktfullPlugin>
    = Future<void> Function(T plugin);

class ImpaktfullCli {
  final ProcessRunner processRunner;

  ImpaktfullCli({
    this.processRunner = const CliProcessRunner(),
  });

  List<Command<dynamic>> get commands => [
        AppleCertificateRootCommand(processRunner: processRunner),
      ];

  List<ImpaktfullPlugin> get _defaultPlugins {
    final onePasswordPlugin = OnePasswordPlugin(processRunner: processRunner);
    final macOsKeyChainPlugin =
        MacOsKeyChainPlugin(processRunner: processRunner);
    final flutterBuildPlugin = FlutterBuildPlugin(processRunner: processRunner);
    final appCenterPlugin = AppCenterPlugin();
    final testflightPlugin = TestFlightPlugin(processRunner: processRunner);
    final playStorePlugin = PlayStorePlugin(processRunner: processRunner);
    return [
      onePasswordPlugin,
      macOsKeyChainPlugin,
      flutterBuildPlugin,
      appCenterPlugin,
      testflightPlugin,
      playStorePlugin,
      CiCdPlugin(
        onePasswordPlugin: onePasswordPlugin,
        macOsKeyChainPlugin: macOsKeyChainPlugin,
        flutterBuildPlugin: flutterBuildPlugin,
        appCenterPlugin: appCenterPlugin,
        testflightPlugin: testflightPlugin,
        playStorePlugin: playStorePlugin,
      ),
    ];
  }

  List<ImpaktfullPlugin> get plugins => [];

  T getPlugin<T extends ImpaktfullPlugin>() {
    var plugin = _defaultPlugins.whereType<T>().firstOrNull;
    plugin ??= plugins.whereType<T>().firstOrNull;
    if (plugin == null) throw ImpaktfullCliError('$T not found in plugins');
    return plugin;
  }

  Future<void> runWithPlugin<T extends ImpaktfullPlugin>(
          ImpaktfullCliSinglePluginRunner<T> runner) =>
      runImpaktfullCli(
        () => runner(getPlugin<T>()),
      );

  Future<void> runWithCli(ImpaktfullCliRunner runner) => runImpaktfullCli(
        () => runner(this),
      );

  Future<void> run(List<String> args) async {
    await runImpaktfullCli(() async {
      final runner = CommandRunner('impaktfull_cli',
          'A cli that replaces `fastlane` by simplifying the CI/CD process.');
      runner.argParser.addGlobalFlags();

      for (final command in commands) {
        runner.addCommand(command);
      }
      final argResults = runner.argParser.parse(args);
      ImpaktfullCliLogger.init(
          isVerboseLoggingEnabled: argResults.isVerboseLoggingEnabled());
      await runner.run(args);
    });
  }
}
