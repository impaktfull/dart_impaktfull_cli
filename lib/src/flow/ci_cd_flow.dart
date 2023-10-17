import 'dart:io';

import 'package:impaktfull_cli/src/model/data/appcenter/appcenter_build_config.dart';
import 'package:impaktfull_cli/src/model/data/build/android_build_extension.dart';
import 'package:impaktfull_cli/src/model/data/build/ios_build_extension.dart';
import 'package:impaktfull_cli/src/model/data/environment/cli_tool.dart';
import 'package:impaktfull_cli/src/model/data/secret.dart';
import 'package:impaktfull_cli/src/plugin/appcenter/appcenter_plugin.dart';
import 'package:impaktfull_cli/src/plugin/flutter/build/flutter_build_plugin.dart';
import 'package:impaktfull_cli/src/plugin/mac_os/keychain/mac_os_keychain_plugin.dart';
import 'package:impaktfull_cli/src/plugin/onePassword/one_password_plugin.dart';
import 'package:impaktfull_cli/src/util/args/env/impaktfull_cli_environment.dart';
import 'package:impaktfull_cli/src/util/args/env/impaktfull_cli_environment_variables.dart';

class CiCdFlow {
  final OnePasswordPlugin onePasswordPlugin;
  final MacOsKeyChainPlugin macOsKeyChainPlugin;
  final AppCenterPlugin appCenterPlugin;

  CiCdFlow({
    this.onePasswordPlugin = const OnePasswordPlugin(),
    this.macOsKeyChainPlugin = const MacOsKeyChainPlugin(),
    this.appCenterPlugin = const AppCenterPlugin(),
  });

  Future<void> buildAndroidWithFlavor({
    required String flavor,
    String mainDartPrefix = 'lib/main_',
    AndroidBuildExtension extension = AndroidBuildExtension.aab,
    bool obfuscate = true,
    String? splitDebugInfoPaths = 'lib/main_',
    int? buildNr,
    AppCenterBuildConfig? appCenterBuildConfig,
  }) async =>
      buildAndroid(
        flavor: flavor,
        mainDartFile: '$mainDartPrefix$flavor.dart',
        extension: extension,
        obfuscate: obfuscate,
        splitDebugInfoPath: '$splitDebugInfoPaths/$flavor.dart',
        appCenterBuildConfig: appCenterBuildConfig,
      );

  Future<void> buildAndroid({
    String? flavor,
    String mainDartFile = 'lib/main.dart',
    AndroidBuildExtension extension = AndroidBuildExtension.aab,
    bool obfuscate = true,
    String? splitDebugInfoPath = '.build/debug-info',
    int? buildNr,
    AppCenterBuildConfig? appCenterBuildConfig,
  }) async {
    ImpaktfullCliEnvironment.requiresInstalledTools([CliTool.flutter]);
    final flutterBuildPlugin = FlutterBuildPlugin();
    final file = await flutterBuildPlugin.buildAndroid(
      flavor: flavor,
      mainDartFile: mainDartFile,
      extension: extension,
      obfuscate: obfuscate,
      splitDebugInfoPath: splitDebugInfoPath,
      buildNr: buildNr,
    );
    if (appCenterBuildConfig != null) {
      await appCenterPlugin.uploadToAppCenter(
        file: file,
        appName: appCenterBuildConfig.appName,
        apiToken: appCenterBuildConfig.apiToken,
        ownerName: appCenterBuildConfig.ownerName,
        distributionGroups: appCenterBuildConfig.distributionGroups,
        notifyListeners: appCenterBuildConfig.notifyListeners,
      );
    }
  }

  Future<void> buildIosWithFlavor({
    required String flavor,
    String mainDartPrefix = 'lib/main_',
    IosBuildExtension extension = IosBuildExtension.ipa,
    bool obfuscate = true,
    String? splitDebugInfoPaths = 'lib/main_',
    int? buildNr,
    AppCenterBuildConfig? appCenterBuildConfig,
  }) async =>
      buildIos(
        flavor: flavor,
        mainDartFile: '$mainDartPrefix$flavor.dart',
        extension: extension,
        obfuscate: obfuscate,
        splitDebugInfoPath: '$splitDebugInfoPaths/$flavor.dart',
        appCenterBuildConfig: appCenterBuildConfig,
      );

  Future<void> buildIos({
    String? flavor,
    String mainDartFile = 'lib/main.dart',
    IosBuildExtension extension = IosBuildExtension.ipa,
    bool obfuscate = true,
    String? splitDebugInfoPath = '.build/debug-info',
    int? buildNr,
    AppCenterBuildConfig? appCenterBuildConfig,
  }) async {
    ImpaktfullCliEnvironment.requiresInstalledTools([CliTool.flutter]);
    final flutterBuildPlugin = FlutterBuildPlugin();
    final file = await flutterBuildPlugin.buildIos(
      flavor: flavor,
      mainDartFile: mainDartFile,
      extension: extension,
      obfuscate: obfuscate,
      splitDebugInfoPath: splitDebugInfoPath,
      buildNr: buildNr,
    );
    if (appCenterBuildConfig != null) {
      await appCenterPlugin.uploadToAppCenter(
        file: file,
        appName: appCenterBuildConfig.appName,
        apiToken: appCenterBuildConfig.apiToken,
        ownerName: appCenterBuildConfig.ownerName,
        distributionGroups: appCenterBuildConfig.distributionGroups,
        notifyListeners: appCenterBuildConfig.notifyListeners,
      );
    }
  }

  Future<void> startBuildWithCertificateAndPasswordFromOnePassword({
    required String opUuid,
    required String keyChainName,
    required Future<void> Function() onStartBuild,
    Secret? globalKeyChainPassword,
  }) async {
    ImpaktfullCliEnvironment.requiresMacOs(reason: 'Building iOS/macOS apps');
    ImpaktfullCliEnvironment.requiresInstalledTools([CliTool.onePasswordCli]);

    final certFile =
        await onePasswordPlugin.downloadDistributionCertificate(opUuid: opUuid);
    final certPassword =
        await onePasswordPlugin.getCertificatePassword(opUuid: opUuid);

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

    await macOsKeyChainPlugin.createKeyChain(
        keyChainName, globalKeyChainPasswordSecret);
    await macOsKeyChainPlugin.unlockKeyChain(
        keyChainName, globalKeyChainPasswordSecret);
    await macOsKeyChainPlugin.addCertificateToKeyChain(
        keyChainName, certFile, certPassword);
    await onStartBuild();
    await macOsKeyChainPlugin.removeKeyChain(keyChainName);
  }
}
