import 'package:args/command_runner.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_plugin.dart';
import 'package:impaktfull_cli/src/core/util/input_listener/force_quit_listener.dart';
import 'package:impaktfull_cli/src/core/util/input_listener/versbose_logging_listener.dart';
import 'package:impaktfull_cli/src/integrations/android/android_command.dart';
import 'package:impaktfull_cli/src/integrations/appcenter/plugin/appcenter_plugin.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_parser_extensions.dart';
import 'package:impaktfull_cli/src/core/util/extensions/arg_result_extensions.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:impaktfull_cli/src/core/util/runner/runner.dart';
import 'package:impaktfull_cli/src/integrations/apple/certificate/plugin/mac_os_keychain_plugin.dart';
import 'package:impaktfull_cli/src/integrations/apple/apple_command.dart';
import 'package:impaktfull_cli/src/integrations/apple/provisioning_profile/plugin/apple_provisioning_profile_plugin.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/ci_cd_command.dart';
import 'package:impaktfull_cli/src/integrations/ci_cd/plugin/ci_cd_plugin.dart';
import 'package:impaktfull_cli/src/integrations/flutter/build/plugin/flutter_build_plugin.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_dashboard/plugin/impaktfull_dashboard_plugin.dart';
import 'package:impaktfull_cli/src/integrations/one_password/plugin/one_password_plugin.dart';
import 'package:impaktfull_cli/src/integrations/open_souce/open_source_command.dart';
import 'package:impaktfull_cli/src/integrations/playstore/plugin/playstore_plugin.dart';
import 'package:impaktfull_cli/src/integrations/slack/plugin/slack_plugin.dart';
import 'package:impaktfull_cli/src/integrations/slack/slack_command.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/plugin/test_coverage_plugin.dart';
import 'package:impaktfull_cli/src/integrations/test_coverage/test_coverage_command.dart';
import 'package:impaktfull_cli/src/integrations/testflight/plugin/testflight_plugin.dart';

typedef ImpaktfullCliRunner<T extends ImpaktfullCli> = Future<void> Function(
    T cli);

class ImpaktfullCli {
  final ProcessRunner processRunner;
  final List<String> arguments;
  late final Set<ImpaktfullPlugin> _defaultPlugins;
  late final Set<Command<dynamic>> _commands;

  ImpaktfullCli({
    this.arguments = const [],
    this.processRunner = const CliProcessRunner(),
  });

  Set<Command<dynamic>> get commands => _commands;

  OnePasswordPlugin get onePasswordPlugin => _getPlugin();

  MacOsKeyChainPlugin get macOsKeyChainPlugin => _getPlugin();

  AppleProvisioningProfilePlugin get appleProvisioningProfilePlugin =>
      _getPlugin();

  FlutterBuildPlugin get flutterBuildPlugin => _getPlugin();

  AppCenterPlugin get appCenterPlugin => _getPlugin();

  TestFlightPlugin get testflightPlugin => _getPlugin();

  PlayStorePlugin get playStorePlugin => _getPlugin();

  CiCdPlugin get ciCdPlugin => _getPlugin();

  Set<ImpaktfullPlugin> get plugins => {};

  bool get isVerboseLoggingEnabled => arguments.contains('-v');

  T _getPlugin<T extends ImpaktfullPlugin>() {
    var plugin = _defaultPlugins.whereType<T>().firstOrNull;
    plugin ??= plugins.whereType<T>().firstOrNull;
    if (plugin == null) throw ImpaktfullCliError('$T not found in plugins');
    return plugin;
  }

  void init() {
    ImpaktfullCliLogger.startSpinner('Initializing the cli');
    ImpaktfullCliLogger.init();
    ImpaktfullCliLogger.enableVerbose(
        isVerboseLoggingEnabled: isVerboseLoggingEnabled);
    _initCommands();
    _initPlugins();
    ForceQuitListener.init();
    ImpaktfullCliLogger.endSpinner();
  }

  void dispose() {
    ForceQuitListener.stopListening();
  }

  void _initCommands() {
    _commands = {
      AndroidRootCommand(processRunner: processRunner),
      AppleRootCommand(processRunner: processRunner),
      CiCdRootCommand(processRunner: processRunner),
      OpenSourceRootCommand(processRunner: processRunner),
      SlackRootCommand(processRunner: processRunner),
      TestCoverageRootCommand(processRunner: processRunner),
    };
  }

  void _initPlugins() {
    final onePasswordPlugin = OnePasswordPlugin(processRunner: processRunner);
    final macOsKeyChainPlugin =
        MacOsKeyChainPlugin(processRunner: processRunner);
    final appleProvisioningProfilePlugin =
        AppleProvisioningProfilePlugin(processRunner: processRunner);
    final flutterBuildPlugin = FlutterBuildPlugin(processRunner: processRunner);
    final appCenterPlugin = AppCenterPlugin();
    final testflightPlugin = TestFlightPlugin(processRunner: processRunner);
    final playStorePlugin = PlayStorePlugin(processRunner: processRunner);
    final impaktfullDashboardPlugin =
        ImpaktfullDashboardPlugin(processRunner: processRunner);
    _defaultPlugins = {
      onePasswordPlugin,
      macOsKeyChainPlugin,
      appleProvisioningProfilePlugin,
      flutterBuildPlugin,
      appCenterPlugin,
      testflightPlugin,
      playStorePlugin,
      impaktfullDashboardPlugin,
      CiCdPlugin(
        onePasswordPlugin: onePasswordPlugin,
        macOsKeyChainPlugin: macOsKeyChainPlugin,
        flutterBuildPlugin: flutterBuildPlugin,
        appCenterPlugin: appCenterPlugin,
        testflightPlugin: testflightPlugin,
        playStorePlugin: playStorePlugin,
        impaktfullDashboardPlugin: impaktfullDashboardPlugin,
      ),
      TestCoveragePlugin(processRunner: processRunner),
      SlackPlugin(processRunner: processRunner),
    };
  }

  Future<void> run(
    ImpaktfullCliRunner<ImpaktfullCli> runner,
  ) async {
    init();
    await runImpaktfullCli(() => runner(this));
    dispose();
  }

  Future<void> runCli() async {
    if (arguments.contains('--version')) {
      ImpaktfullCliLogger.log('impaktfull_cli stable');
      return;
    }
    init();
    await runImpaktfullCli(() async {
      final runner = CommandRunner(
        'impaktfull_cli',
        'A cli that replaces `fastlane` by simplifying the CI/CD process.',
      );
      runner.argParser.addGlobalFlags();

      for (final command in commands) {
        runner.addCommand(command);
      }
      final argResults = runner.argParser.parse(arguments);
      ImpaktfullCliLogger.enableVerbose(
          isVerboseLoggingEnabled: argResults.isVerboseLoggingEnabled());
      await runner.run(arguments);
    });
    dispose();
  }

  Future<void> runMultipleCommands(AsyncCallback function) async {
    VerboseLoggingListener.setupMutiCommandInputListener();
    await function();
    VerboseLoggingListener.clearMultipleCommandInputListener();
  }
}
