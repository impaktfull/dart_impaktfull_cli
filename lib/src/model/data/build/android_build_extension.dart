enum AndroidBuildExtension {
  apk('apk', 'apk'),
  abb('appbundle', 'aab');

  final String flutterBuildArgument;
  final String fileExtension;

  const AndroidBuildExtension(
    this.flutterBuildArgument,
    this.fileExtension,
  );
}
