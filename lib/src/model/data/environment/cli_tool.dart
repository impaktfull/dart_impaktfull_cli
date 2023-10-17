import 'package:impaktfull_cli/src/model/data/environment/operating_system.dart';

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
  ),
  onePasswordCli(
    name: '1password cli',
    commandName: 'op',
  ),
  adb(
    name: 'Android development tools (adb)',
    commandName: 'adb',
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
  final List<OperatingSystem> supportedOperatingSystems;

  const CliTool({
    required this.name,
    required this.commandName,
    this.supportedOperatingSystems = OperatingSystem.values,
  });
}
