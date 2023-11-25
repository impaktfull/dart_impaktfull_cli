import 'package:impaktfull_cli/src/core/model/data/environment/operating_system.dart';

enum CliTool {
  dart(
    name: 'Dart',
    commandName: 'dart',
  ),
  flutter(
    name: 'Flutter',
    commandName: 'flutter',
  ),
  fvm(
    name: 'Flutter Version Manager (fvm)',
    commandName: 'fvm',
    installationInstructions: {
      OperatingSystem.macOS:
          'https://fvm.app/docs/getting_started/installation/',
    },
  ),
  onePasswordCli(
    name: '1password cli',
    commandName: 'op',
  ),
  adb(
    name: 'Android development tools (adb)',
    commandName: 'adb',
  ),
  aapt2(
    name: 'Android Asset Packaging Tool',
    commandName: 'aapt',
  ),
  bundleTool(
    name: 'Bundle Tool',
    commandName: 'bundleTool',
    installationInstructions: {
      OperatingSystem.macOS: 'brew install bundletool',
    },
  ),
  xcodeSelect(
    name: 'xCode Select',
    commandName: 'xcode-select',
    supportedOperatingSystems: [
      OperatingSystem.macOS,
    ],
  ),
  cocoaPods(
    name: 'CocoaPods',
    commandName: 'pod',
    supportedOperatingSystems: [
      OperatingSystem.macOS,
    ],
  ),
  git(
    name: 'git',
    commandName: 'git',
  ),
  security(
    name: 'security (KeyChain)',
    commandName: 'security',
    supportedOperatingSystems: [
      OperatingSystem.macOS,
    ],
  );

  final String name;
  final String commandName;
  final Map<OperatingSystem, String> installationInstructions;
  final List<OperatingSystem> supportedOperatingSystems;

  const CliTool({
    required this.name,
    required this.commandName,
    this.installationInstructions = const {},
    this.supportedOperatingSystems = OperatingSystem.values,
  });
}
