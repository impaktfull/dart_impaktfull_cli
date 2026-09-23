import 'dart:io';

enum OperatingSystem {
  macOS(
    name: 'macOS',
  ),
  linux(
    name: 'Linux',
  ),
  windows(
    name: 'Windows',
  );

  final String name;

  const OperatingSystem({
    required this.name,
  });

  static OperatingSystem get current {
    if (Platform.isMacOS) {
      return OperatingSystem.macOS;
    } else if (Platform.isLinux) {
      return OperatingSystem.linux;
    } else if (Platform.isWindows) {
      return OperatingSystem.windows;
    }
    throw Exception('Current operating system is not yet supported');
  }
}
