import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/util/args/env/impaktfull_cli_environment_variables.dart';

/// The credential the appstore CI surface takes: an upload key.
///
/// The key IS the app. No route on `/api/ci/*` takes an app id, which removes a
/// whole class of CI mistake: an app id in a YAML file and a key in a secret
/// store can drift apart, and the result is a build uploaded into the wrong
/// product.
class ImpaktfullAppstoreCredentials {
  /// Starts with `ifas_uk_`. Created in the app's settings and shown once.
  final Secret uploadKey;

  const ImpaktfullAppstoreCredentials({
    required this.uploadKey,
  });

  /// Reads `IMPAKTFULL_APPSTORE_UPLOAD_KEY`.
  ///
  /// Registering it as a [Secret] is what masks it in every log line the CLI
  /// writes afterwards, so a verbose run in CI does not print the credential
  /// into a log somebody else can read.
  factory ImpaktfullAppstoreCredentials.fromEnvironment() =>
      ImpaktfullAppstoreCredentials(
        uploadKey:
            ImpaktfullCliEnvironmentVariables.getImpaktfullAppstoreUploadKey(),
      );
}
