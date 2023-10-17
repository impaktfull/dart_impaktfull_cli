enum IosBuildExtension {
  ipa('ipa', 'ipa');

  final String flutterBuildArgument;
  final String fileExtension;

  const IosBuildExtension(
    this.flutterBuildArgument,
    this.fileExtension,
  );
}
