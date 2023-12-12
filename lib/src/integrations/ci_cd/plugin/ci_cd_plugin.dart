import 'dart:io';

import 'package:impaktfull_cli/src/core/plugin/impaktfull_plugin.dart';
import 'package:impaktfull_cli/src/integrations/appcenter/plugin/appcenter_plugin.dart';
import 'package:impaktfull_cli/src/integrations/apple_certificate/plugin/mac_os_keychain_plugin.dart';
import 'package:impaktfull_cli/src/integrations/appcenter/model/appcenter_upload_config.dart';
import 'package:impaktfull_cli/src/core/model/data/environment/cli_tool.dart';
import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment_variables.dart';
import 'package:impaktfull_cli/src/integrations/flutter/build/model/flutter_build_android_extension.dart';
import 'package:impaktfull_cli/src/integrations/flutter/build/model/flutter_build_ios_extension.dart';
import 'package:impaktfull_cli/src/integrations/flutter/build/plugin/flutter_build_plugin.dart';
import 'package:impaktfull_cli/src/integrations/one_password/plugin/one_password_plugin.dart';
import 'package:impaktfull_cli/src/integrations/playstore/model/playstore_upload_config.dart';
import 'package:impaktfull_cli/src/integrations/playstore/plugin/playstore_plugin.dart';
import 'package:impaktfull_cli/src/integrations/testflight/model/testflight_upload_config.dart';
import 'package:impaktfull_cli/src/integrations/testflight/plugin/testflight_plugin.dart';

class CiCdPlugin extends ImpaktfullPlugin {
  final OnePasswordPlugin onePasswordPlugin;
  final MacOsKeyChainPlugin macOsKeyChainPlugin;
  final FlutterBuildPlugin flutterBuildPlugin;
  final AppCenterPlugin appCenterPlugin;
  final TestFlightPlugin testflightPlugin;
  final PlayStorePlugin playStorePlugin;

  const CiCdPlugin({
    required this.onePasswordPlugin,
    required this.macOsKeyChainPlugin,
    required this.flutterBuildPlugin,
    required this.appCenterPlugin,
    required this.testflightPlugin,
    required this.playStorePlugin,
  });

  Future<void> buildAndroidWithFlavor({
    required String flavor,
    String mainDartPrefix = 'lib/main_',
    FlutterBuildAndroidExtension extension = FlutterBuildAndroidExtension.aab,
    bool obfuscate = true,
    String? splitDebugInfoPaths = 'lib/main_',
    int? buildNr,
    AppCenterUploadConfig? appCenterUploadConfig,
    PlayStoreUploadConfig? playStoreUploadConfig,
  }) async =>
      buildAndroid(
        flavor: flavor,
        mainDartFile: '$mainDartPrefix$flavor.dart',
        extension: extension,
        obfuscate: obfuscate,
        splitDebugInfoPath: '$splitDebugInfoPaths/$flavor.dart',
        appCenterUploadConfig: appCenterUploadConfig,
        playStoreUploadConfig: playStoreUploadConfig,
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
        serviceAccountCredentialsFile: playStoreUploadConfig.serviceAccountCredentialsFile,
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
  }) async =>
      buildIos(
        flavor: flavor,
        mainDartFile: '$mainDartPrefix$flavor.dart',
        extension: extension,
        obfuscate: obfuscate,
        splitDebugInfoPath: '$splitDebugInfoPaths/$flavor.dart',
        appCenterUploadConfig: appCenterUploadConfig,
        testflightUploadConfig: testflightUploadConfig,
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
        appSpecificPassword: testflightUploadConfig.credentials?.appSpecificPassword,
        type: testflightUploadConfig.type,
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
    final globalKeyChainPasswordSecret = globalKeyChainPassword ?? ImpaktfullCliEnvironmentVariables.getUnlockKeyChainPassword();

    await macOsKeyChainPlugin.createKeyChain(keyChainName, globalKeyChainPasswordSecret);
    try {
      await macOsKeyChainPlugin.unlockKeyChain(keyChainName, globalKeyChainPasswordSecret);
      await macOsKeyChainPlugin.addCertificateToKeyChain(keyChainName, certFile, certPassword, accessControlAll: true);
      await onStartBuild();
    } catch (e) {
      rethrow;
    } finally {
      await macOsKeyChainPlugin.removeKeyChain(keyChainName);
    }
  }
}
