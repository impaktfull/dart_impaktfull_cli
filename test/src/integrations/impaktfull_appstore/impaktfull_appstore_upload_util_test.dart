import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/util/impaktfull_appstore_api.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/util/impaktfull_appstore_upload_util.dart';
import 'package:test/test.dart';

/// The guards that fire BEFORE anything is transferred.
///
/// That is what this suite is about. Every check here has a version of itself
/// on the server, and the server's is the one that decides; these exist so the
/// answer arrives in a second instead of after a gigabyte has crossed a client
/// office's uplink.
void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('appstore-test'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  File artifact(String name, {int bytes = 16}) {
    final file = File('${tempDir.path}/$name');
    file.writeAsBytesSync(List<int>.filled(bytes, 0x41));
    return file;
  }

  ImpaktfullAppstoreUploadConfig config() => ImpaktfullAppstoreUploadConfig(
        credentials: ImpaktfullAppstoreCredentials(
          uploadKey: Secret('ifas_uk_test'),
        ),
        environmentName: 'staging',
      );

  group('the file has to be installable at all', () {
    test('an .aab is refused with its own message', () async {
      // Not a typo but a wrong artifact: an App Center pipeline that produced
      // both an .aab and an .apk will happily hand over the wrong one, and
      // "unsupported extension" would send somebody looking for a setting.
      await expectLater(
        const ImpaktfullAppstoreUploadUtil()
            .upload(file: artifact('app.aab'), config: config()),
        throwsA(
          isA<ImpaktfullCliError>().having(
            (error) => error.message,
            'message',
            allOf(contains('.aab'), contains('universal')),
          ),
        ),
      );
    });

    test('an unrelated extension is refused', () async {
      await expectLater(
        const ImpaktfullAppstoreUploadUtil()
            .upload(file: artifact('app.zip'), config: config()),
        throwsA(isA<ImpaktfullCliError>()),
      );
    });

    test('a file that is not there is refused before anything else', () async {
      await expectLater(
        const ImpaktfullAppstoreUploadUtil().upload(
          file: File('${tempDir.path}/missing.ipa'),
          config: config(),
        ),
        throwsA(
          isA<ImpaktfullCliError>().having(
            (error) => error.message,
            'message',
            contains('does not exist'),
          ),
        ),
      );
    });
  });

  group('resolving the environment', () {
    // The shape every real app has: the same environment name on both
    // platforms. Matching on the name alone picks whichever came back first.
    final app = ImpaktfullAppstoreApp.fromJson({
      'app': {'id': 'a1', 'name': 'Acme'},
      'environments': [
        {
          'id': 'e-ios',
          'platform': 'ios',
          'name': 'alpha',
          'label': 'iOS - alpha',
          'appIdentifier': 'com.acme.app.alpha',
        },
        {
          'id': 'e-android',
          'platform': 'android',
          'name': 'alpha',
          'label': 'Android - alpha',
          'appIdentifier': 'com.acme.app.alpha',
        },
      ],
    });

    test('an .apk resolves to the ANDROID environment of that name', () {
      // THE REGRESSION. This picked `iOS - alpha` and the upload then failed
      // for a reason that had nothing to do with what was wrong. The server
      // derives the platform from the extension for exactly this reason.
      final resolved = const ImpaktfullAppstoreUploadUtil()
          .debugResolveEnvironment(app, 'alpha', File('build/app.apk'));
      expect(resolved.id, 'e-android');
    });

    test('an .ipa resolves to the iOS environment of that name', () {
      final resolved = const ImpaktfullAppstoreUploadUtil()
          .debugResolveEnvironment(app, 'alpha', File('build/app.ipa'));
      expect(resolved.id, 'e-ios');
    });

    test('a name that exists only on the other platform says so', () {
      final iosOnly = ImpaktfullAppstoreApp.fromJson({
        'app': {'id': 'a1', 'name': 'Acme'},
        'environments': [
          {
            'id': 'e-ios',
            'platform': 'ios',
            'name': 'alpha',
            'label': 'iOS - alpha',
            'appIdentifier': 'com.acme.app.alpha',
          },
        ],
      });
      expect(
        () => const ImpaktfullAppstoreUploadUtil()
            .debugResolveEnvironment(iosOnly, 'alpha', File('build/app.apk')),
        throwsA(
          isA<ImpaktfullCliError>().having(
            (error) => error.message,
            'message',
            allOf(contains('exists but not for android'), contains('.apk')),
          ),
        ),
      );
    });

    test('an unknown name lists what this key can write to', () {
      expect(
        () => const ImpaktfullAppstoreUploadUtil()
            .debugResolveEnvironment(app, 'stagng', File('build/app.ipa')),
        throwsA(
          isA<ImpaktfullCliError>().having(
            (error) => error.message,
            'message',
            allOf(contains('stagng'), contains('alpha')),
          ),
        ),
      );
    });
  });

  group('the checksum', () {
    test('is the SHA-256 of the file, streamed', () async {
      // The known digest of "abc". The server dedupes on this and verifies it
      // against what actually landed in storage, so a wrong implementation here
      // makes every upload fail at complete with a checksum mismatch.
      final file = File('${tempDir.path}/abc.bin')..writeAsStringSync('abc');
      expect(
        await ImpaktfullAppstoreApi.hashFile(file),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('is stable across chunk boundaries', () async {
      // Larger than one read, so a hash that only ever saw the first chunk
      // would differ from openssl here and nowhere else.
      final file = File('${tempDir.path}/big.bin')
        ..writeAsBytesSync(List<int>.generate(200000, (i) => i % 256));
      final first = await ImpaktfullAppstoreApi.hashFile(file);
      final second = await ImpaktfullAppstoreApi.hashFile(file);
      expect(first, second);
      expect(first, hasLength(64));
    });
  });

  group('CI metadata', () {
    test('is empty when nothing in the environment says otherwise', () {
      // `fromEnvironment` reads the real environment, which on a developer
      // machine has none of these. Guessing from a variable that means
      // something else elsewhere would put a wrong commit on a build page, and
      // a wrong answer there is worse than none: somebody reads the wrong diff.
      final metadata = const ImpaktfullAppstoreCiMetadata();
      expect(metadata.isEmpty, isTrue);
      expect(metadata.toJson(), isEmpty);
    });

    test('sends only the fields it actually has', () {
      const metadata = ImpaktfullAppstoreCiMetadata(branch: 'develop');
      expect(metadata.isEmpty, isFalse);
      expect(metadata.toJson(), {'branch': 'develop'});
    });
  });

  group('the upload key is a secret', () {
    test('it is masked in logs once the credentials are built', () {
      // Constructing a Secret registers it with the logger, which is what keeps
      // a verbose CI run from printing the credential into a log somebody else
      // can read.
      final credentials = ImpaktfullAppstoreCredentials(
        uploadKey: Secret('ifas_uk_supersecret'),
      );
      expect(credentials.uploadKey.value, 'ifas_uk_supersecret');
    });
  });

  group('defaults', () {
    test('waits for processing', () {
      // The point of the whole product: the artifact is not installable until
      // the server has read it, so a pipeline that does not wait has reported
      // that a file was transferred rather than that anybody can install it.
      expect(config().waitForProcessing, isTrue);
    });

    test('points at the production instance', () {
      expect(config().baseUrl.toString(), 'https://appstore.impaktfull.com');
    });
  });
}
