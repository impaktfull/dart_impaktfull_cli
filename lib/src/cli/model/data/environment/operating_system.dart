import 'dart:io';

enum OperatingSystem {
  macOS(
    name: 'macOS',
  );

  final String name;

  const OperatingSystem({
    required this.name,
  });

  static OperatingSystem get current {
    if (Platform.isMacOS) {
      return OperatingSystem.macOS;
    }
    throw Exception('Current operating system is not yet supported');
  }
}
