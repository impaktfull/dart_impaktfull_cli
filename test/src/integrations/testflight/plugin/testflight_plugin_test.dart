import 'package:impaktfull_cli/src/integrations/testflight/plugin/testflight_plugin.dart';
import 'package:test/test.dart';

void main() {
  group('TestFlightPlugin.failedUploadError', () {
    test('is null for a successful upload', () {
      const output = '''
Running altool at path '/Applications/Xcode.app/Contents/SharedFrameworks/ContentDeliveryServices.framework/Frameworks/AppStoreService.framework/Support/altool'...
2026-10-22 21:14:03.512 *** No errors uploading 'build/ios/ipa/Runner.ipa'
UPLOAD SUCCEEDED with no errors''';
      expect(TestFlightPlugin.failedUploadError(output), isNull);
    });

    test('fails a rejected upload that exited with 0', () {
      const output = '''
Running altool at path '/Applications/Xcode.app/Contents/SharedFrameworks/ContentDeliveryServices.framework/Frameworks/AppStoreService.framework/Support/altool'...
ERROR: [altool.600000D8C000] Validation failed (409) Invalid bundle. The "UIInterfaceOrientationPortrait" orientations were provided for the UISupportedInterfaceOrientations Info.plist key, but you need to include all of the "UIInterfaceOrientationPortrait,UIInterfaceOrientationPortraitUpsideDown,UIInterfaceOrientationLandscapeLeft,UIInterfaceOrientationLandscapeRight" orientations to support iPad multitasking.
UPLOAD FAILED with 1 error''';
      final error = TestFlightPlugin.failedUploadError(output);
      expect(error, isNotNull);
      expect(error!.message, contains('Uploading to testflight failed'));
      expect(error.message, contains('Validation failed (409)'));
    });

    test('fails on an error line without the summary', () {
      const output = '*** Error: Error uploading \'Runner.ipa\'.';
      expect(TestFlightPlugin.failedUploadError(output), isNotNull);
    });

    test('maps a known failure to its message', () {
      const output = '''
ERROR: ContentDelivery Code=90062 The value for key CFBundleVersion must be higher.
UPLOAD FAILED with 1 error''';
      expect(
        TestFlightPlugin.failedUploadError(output)!.message,
        'The bundle version must be higher than the previously uploaded version',
      );
    });
  });
}
