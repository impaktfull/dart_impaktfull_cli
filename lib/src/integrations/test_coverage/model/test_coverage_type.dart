enum TestCoverageType {
  lcovInfo(name: 'lcov.info');

  final String name;

  const TestCoverageType({
    required this.name,
  });
}
