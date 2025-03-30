class TestCoverageIgnoreUtil {
  static List<RegExp> defaultIgnorePatterns = [
    RegExp(r'.*\.g\.dart$'),
    RegExp(r'.*\.navigator\.dart$'),
    RegExp(r'.*/injectable\.config\.dart$'),
    RegExp(r'.*server/lib/src/generated/protocol\.dart$'),
    RegExp(r'.*server/lib/src/generated/endpoints\.dart$'),
    RegExp(r'.*server/lib/src/generated/serverpod/.*\.dart$'),
  ];
}
