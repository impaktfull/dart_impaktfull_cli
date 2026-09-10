import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/model/impaktfull_appstore_ci_metadata.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/model/impaktfull_appstore_credentials.dart';

/// What to upload, and where.
class ImpaktfullAppstoreUploadConfig {
  /// Credentials to authenticate to the impaktfull appstore.
  final ImpaktfullAppstoreCredentials credentials;

  /// The environment to upload to, by name: `staging`, `acceptance`,
  /// `production`. Lowercase, because that is what the server accepts and a
  /// name whose case matters is a pipeline that breaks on a capital letter
  /// typed months later in another repository.
  final String environmentName;

  /// Shown to every tester of this app on the build page and in the email they
  /// get. Plain text; links are made clickable and nothing else is rendered.
  final String? releaseNotes;

  /// Commit, branch and run URL. Read from the CI environment when omitted, so
  /// a build page links back to the pipeline that produced it without every
  /// project having to wire it up.
  final ImpaktfullAppstoreCiMetadata? ci;

  /// Wait for the server to finish inspecting the build.
  ///
  /// On by default, and that is the point of the whole product: the artifact is
  /// not installable until it has been validated, and a pipeline that reports
  /// success before that has reported that the file was transferred rather than
  /// that anybody can install it.
  final bool waitForProcessing;

  /// How long to wait for processing before giving up. The build is not lost
  /// when this elapses; the pipeline just stops watching.
  final Duration processingTimeout;

  /// Where the appstore lives. Only ever changed for a test instance.
  final Uri baseUrl;

  static final defaultBaseUrl = Uri.parse('https://appstore.impaktfull.com');

  ImpaktfullAppstoreUploadConfig({
    required this.credentials,
    required this.environmentName,
    this.releaseNotes,
    this.ci,
    this.waitForProcessing = true,
    this.processingTimeout = const Duration(minutes: 10),
    Uri? baseUrl,
  }) : baseUrl = baseUrl ?? defaultBaseUrl;
}
