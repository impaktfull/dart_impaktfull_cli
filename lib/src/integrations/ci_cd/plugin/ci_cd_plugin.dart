import 'dart:convert';
import 'dart:io';

import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';
import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/input_listener/force_quit_listener.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:impaktfull_cli/src/integrations/appcenter/plugin/appcenter_plugin.dart';
import 'package:impaktfull_cli/src/integrations/apple/certificate/plugin/mac_os_keychain_plugin.dart';
import 'package:impaktfull_cli/src/integrations/appcenter/model/appcenter_upload_config.dart';
import 'package:impaktfull_cli/src/core/model/data/environment/cli_tool.dart';
import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment_variables.dart';
import 'package:impaktfull_cli/src/integrations/flutter/build/model/flutter_build_android_extension.dart';
import 'package:impaktfull_cli/src/integrations/flutter/build/model/flutter_build_ios_extension.dart';
import 'package:impaktfull_cli/src/integrations/flutter/build/plugin/flutter_build_plugin.dart';
import 'package:impaktfull_cli/src/integrations/git/plugin/git_plugin.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_dashboard/model/impaktfull_dashboard_app_testing_version_upload_config.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_dashboard/plugin/impaktfull_dashboard_plugin.dart';
import 'package:impaktfull_cli/src/integrations/one_password/plugin/one_password_plugin.dart';
import 'package:impaktfull_cli/src/integrations/playstore/model/playstore_upload_config.dart';
import 'package:impaktfull_cli/src/integrations/playstore/plugin/playstore_plugin.dart';
import 'package:impaktfull_cli/src/integrations/testflight/model/testflight_upload_config.dart';
import 'package:impaktfull_cli/src/integrations/testflight/plugin/testflight_plugin.dart';

class CiCdPlugin extends ImpaktfullCliPlugin {
  final OnePasswordPlugin onePasswordPlugin;
  final MacOsKeyChainPlugin macOsKeyChainPlugin;
  final FlutterBuildPlugin flutterBuildPlugin;
  final AppCenterPlugin appCenterPlugin;
  final TestFlightPlugin testflightPlugin;
  final PlayStorePlugin playStorePlugin;
  final ImpaktfullDashboardPlugin impaktfullDashboardPlugin;
  final GitPlugin gitPlugin;

  const CiCdPlugin({
    required this.onePasswordPlugin,
    required this.macOsKeyChainPlugin,
    required this.flutterBuildPlugin,
    required this.appCenterPlugin,
    required this.testflightPlugin,
    required this.playStorePlugin,
    required this.impaktfullDashboardPlugin,
    required this.gitPlugin,
    super.processRunner = const CliProcessRunner(),
  });

  Future<int> getGithubBuildNr({
    required String flavor,
    required String suffix,
  }) async {
    final githubBuildNr = ImpaktfullCliEnvironmentVariables.getGithubBuildNr();
    final buildNr = int.tryParse(githubBuildNr);
    if (buildNr == null) {
      throw ImpaktfullCliError(
          '`${ImpaktfullCliEnvironmentVariables.envKeyGithubBuildNr}` is not a valid number: $githubBuildNr');
    }
    return buildNr;
  }

  /// Bumps the version of the app in release_config.yaml
  /// Commits the change & returns the build_nr of the new version
  Future<int> versionBump({
    String? flavor,
    String? suffix,
    bool commitChanges = true,
  }) async {
    ImpaktfullCliLogger.setSpinnerPrefix('VersionBump');
    ImpaktfullCliLogger.startSpinner('Validating git clean');
    await gitPlugin.validateGitClean();
    final isGitProject = await gitPlugin.isGitProject();
    final file = File('release_config.json');
    var newConfigData = <String, dynamic>{};
    var buildNr = 0;
    var buildNrKey = 'build_nr';
    if (flavor != null) {
      buildNrKey += '_$flavor';
    }
    if (suffix != null) {
      buildNrKey += '_$suffix';
    }
    ImpaktfullCliLogger.startSpinner('bumping for `$buildNrKey`');
    if (file.existsSync()) {
      final content = file.readAsStringSync();
      final orignalConfigData = jsonDecode(content) as Map<String, dynamic>;
      newConfigData = orignalConfigData;
      if (orignalConfigData.containsKey(buildNrKey)) {
        buildNr = orignalConfigData[buildNrKey] as int;
      }
    }
    buildNr++;
    ImpaktfullCliLogger.verbose(
        'New build_nr: $buildNr (for key: $buildNrKey)');
    newConfigData[buildNrKey] = buildNr;
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    final encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync(encoder.convert(newConfigData));
    if (commitChanges && isGitProject) {
      await processRunner.runProcess([
        'git',
        'add',
        'release_config.json',
      ]);
      await processRunner.runProcess([
        'git',
        'commit',
        '-m',
        'Bump build_nr to $buildNr (for key: $buildNrKey)',
      ]);
    }
    ImpaktfullCliLogger.clearSpinnerPrefix();
    return buildNr;
  }

  Future<void> buildAndroidWithFlavor({
    required String flavor,
    String mainDartPrefix = 'lib/main_',
    FlutterBuildAndroidExtension extension = FlutterBuildAndroidExtension.aab,
    bool obfuscate = true,
    String? splitDebugInfoPaths = 'lib/main_',
    int? buildNr,
    AppCenterUploadConfig? appCenterUploadConfig,
    PlayStoreUploadConfig? playStoreUploadConfig,
    ImpaktfullDashboardAppTestingVersionUploadConfig?
        impaktfullDashboardUploadConfig,
  }) async =>
      buildAndroid(
        flavor: flavor,
        mainDartFile: '$mainDartPrefix$flavor.dart',
        extension: extension,
        obfuscate: obfuscate,
        splitDebugInfoPath: '$splitDebugInfoPaths/$flavor.dart',
        buildNr: buildNr,
        appCenterUploadConfig: appCenterUploadConfig,
        playStoreUploadConfig: playStoreUploadConfig,
        impaktfullDashboardUploadConfig: impaktfullDashboardUploadConfig,
      );

  Future<void> buildAndroid({
    String? flavor,
    String mainDartFile = 'lib/main.dart',
    FlutterBuildAndroidExtension extension = FlutterBuildAndroidExtension.aab,
    bool obfuscate = true,
    String? splitDebugInfoPath = '.build/debug-info',
    int? buildNr,
    AppCenterUploadConfig? appCenterUploadConfig,
    PlayStoreUploadConfig? playStoreUploadConfig,
    ImpaktfullDashboardAppTestingVersionUploadConfig?
        impaktfullDashboardUploadConfig,
  }) async {
    ImpaktfullCliEnvironment.requiresInstalledTools([CliTool.flutter]);
    final file = await flutterBuildPlugin.buildAndroid(
      flavor: flavor,
      mainDartFile: mainDartFile,
      extension: extension,
      obfuscate: obfuscate,
      splitDebugInfoPath: splitDebugInfoPath,
      buildNr: buildNr,
    );
    if (appCenterUploadConfig != null) {
      await appCenterPlugin.uploadToAppCenter(
        file: file,
        appName: appCenterUploadConfig.appName,
        apiToken: appCenterUploadConfig.apiToken,
        ownerName: appCenterUploadConfig.ownerName,
        distributionGroups: appCenterUploadConfig.distributionGroups,
        notifyListeners: appCenterUploadConfig.notifyListeners,
      );
    }
    if (playStoreUploadConfig != null) {
      await playStorePlugin.uploadToPlayStore(
        file: file,
        serviceAccountCredentialsFile:
            playStoreUploadConfig.serviceAccountCredentialsFile,
        trackType: playStoreUploadConfig.trackType,
        releaseStatus: playStoreUploadConfig.releaseStatus,
      );
    }
    if (impaktfullDashboardUploadConfig != null) {
      await impaktfullDashboardPlugin
          .uploadAppTestingVersionToImpaktfullDashboard(
        file: file,
        config: impaktfullDashboardUploadConfig,
      );
    }
  }

  Future<void> buildIosWithFlavor({
    required String flavor,
    String mainDartPrefix = 'lib/main_',
    FlutterBuildIosExtension extension = FlutterBuildIosExtension.ipa,
    bool obfuscate = true,
    String? splitDebugInfoPaths = 'lib/main_',
    int? buildNr,
    AppCenterUploadConfig? appCenterUploadConfig,
    TestFlightUploadConfig? testflightUploadConfig,
    ImpaktfullDashboardAppTestingVersionUploadConfig?
        impaktfullDashboardUploadConfig,
  }) async =>
      buildIos(
        flavor: flavor,
        mainDartFile: '$mainDartPrefix$flavor.dart',
        extension: extension,
        obfuscate: obfuscate,
        splitDebugInfoPath: '$splitDebugInfoPaths/$flavor.dart',
        buildNr: buildNr,
        appCenterUploadConfig: appCenterUploadConfig,
        testflightUploadConfig: testflightUploadConfig,
        impaktfullDashboardUploadConfig: impaktfullDashboardUploadConfig,
      );

  Future<void> buildIos({
    String? flavor,
    String mainDartFile = 'lib/main.dart',
    FlutterBuildIosExtension extension = FlutterBuildIosExtension.ipa,
    bool obfuscate = true,
    String? splitDebugInfoPath = '.build/debug-info',
    int? buildNr,
    AppCenterUploadConfig? appCenterUploadConfig,
    TestFlightUploadConfig? testflightUploadConfig,
    ImpaktfullDashboardAppTestingVersionUploadConfig?
        impaktfullDashboardUploadConfig,
  }) async {
    ImpaktfullCliEnvironment.requiresInstalledTools([
      CliTool.flutter,
      CliTool.cocoaPods,
      if (testflightUploadConfig != null) CliTool.xcodeSelect,
    ]);
    final file = await flutterBuildPlugin.buildIos(
      flavor: flavor,
      mainDartFile: mainDartFile,
      extension: extension,
      obfuscate: obfuscate,
      splitDebugInfoPath: splitDebugInfoPath,
      buildNr: buildNr,
    );
    if (appCenterUploadConfig != null) {
      await appCenterPlugin.uploadToAppCenter(
        file: file,
        appName: appCenterUploadConfig.appName,
        apiToken: appCenterUploadConfig.apiToken,
        ownerName: appCenterUploadConfig.ownerName,
        distributionGroups: appCenterUploadConfig.distributionGroups,
        notifyListeners: appCenterUploadConfig.notifyListeners,
      );
    }
    if (testflightUploadConfig != null) {
      await testflightPlugin.uploadToTestflightWithEmailPassword(
        file: file,
        email: testflightUploadConfig.credentials?.userName,
        appSpecificPassword:
            testflightUploadConfig.credentials?.appSpecificPassword,
        type: testflightUploadConfig.type,
      );
    }
    if (impaktfullDashboardUploadConfig != null) {
      await impaktfullDashboardPlugin
          .uploadAppTestingVersionToImpaktfullDashboard(
        file: file,
        config: impaktfullDashboardUploadConfig,
      );
    }
  }

  Future<void> startBuildWithCertificateAndPasswordFromOnePassword({
    required String opUuid,
    required String opVaultName,
    required String keyChainName,
    required Future<void> Function() onStartBuild,
    Secret? rawServiceAccount,
    Secret? globalKeyChainPassword,
  }) async {
    ImpaktfullCliEnvironment.requiresMacOs(reason: 'Building iOS/macOS apps');
    ImpaktfullCliEnvironment.requiresInstalledTools([CliTool.onePasswordCli]);

    final certFile = await onePasswordPlugin.downloadDistributionCertificate(
      opUuid: opUuid,
      rawServiceAccount: rawServiceAccount,
    );
    final certPassword = await onePasswordPlugin.getCertificatePassword(
      vaultName: opVaultName,
      opUuid: opUuid,
      rawServiceAccount: rawServiceAccount,
    );

    await startBuildWithCertificateAndPassword(
      keyChainName: keyChainName,
      certFile: certFile,
      certPassword: certPassword,
      onStartBuild: onStartBuild,
      globalKeyChainPassword: globalKeyChainPassword,
    );
  }

  Future<void> startBuildWithCertificateAndPassword({
    required String keyChainName,
    required File certFile,
    required Secret certPassword,
    required Future<void> Function() onStartBuild,
    Secret? globalKeyChainPassword,
  }) async {
    ImpaktfullCliEnvironment.requiresMacOs(reason: 'Building iOS/macOS apps');
    final globalKeyChainPasswordSecret = globalKeyChainPassword ??
        ImpaktfullCliEnvironmentVariables.getUnlockKeyChainPassword();

    final defaultKeyChain = await macOsKeyChainPlugin.getDefaultKeyChain();
    await macOsKeyChainPlugin.createKeyChain(
        keyChainName, globalKeyChainPasswordSecret);

    await ForceQuitListener.catchForceQuit(
      () async {
        await macOsKeyChainPlugin.setDefaultKeyChain(keyChainName);
        // await macOsKeyChainPlugin.unlockKeyChain(keyChainName, globalKeyChainPasswordSecret);
        await macOsKeyChainPlugin.addCertificateToKeyChain(
          keyChainName,
          certFile,
          certPassword,
          accessControlAll: true,
        );
        await onStartBuild();
      },
      cleanup: () async {
        await macOsKeyChainPlugin.setDefaultKeyChain(defaultKeyChain);
        await macOsKeyChainPlugin.removeKeyChain(keyChainName);
      },
    );
  }
}
