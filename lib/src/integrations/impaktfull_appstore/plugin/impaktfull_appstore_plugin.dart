import 'dart:io';

import 'package:impaktfull_cli/src/core/plugin/impaktfull_cli_plugin.dart';
import 'package:impaktfull_cli/src/core/util/logger/logger.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/model/impaktfull_appstore_build.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/model/impaktfull_appstore_upload_config.dart';
import 'package:impaktfull_cli/src/integrations/impaktfull_appstore/util/impaktfull_appstore_upload_util.dart';

/// Uploads test builds to the impaktfull appstore.
///
/// This replaces both App Center Distribute, which was retired in March 2025,
/// and the App Testing upload in the impaktfull dashboard. What changes for a
/// pipeline, beyond the host:
///
///  - The artifact goes STRAIGHT TO STORAGE with a presigned PUT and is
///    streamed from disk, so a gigabyte does not pass through an API server or
///    sit in this process's heap.
///  - The upload key is scoped to one app and a set of environments, and it is
///    verified by hash. The dashboard treated the presence of a header as
///    authorisation.
///  - Nothing is installable until the server has opened the artifact and read
///    it. This waits for that by default and fails the pipeline with the
///    reason, rather than reporting success for a file a tester cannot install.
///  - Artifacts are never on a public URL. Every install goes through a token
///    bound to a person and re-checked on every fetch.
class ImpaktfullAppstorePlugin extends ImpaktfullCliPlugin {
  const ImpaktfullAppstorePlugin({
    required super.processRunner,
  });

  /// Uploads [file] and returns the build once the server has inspected it.
  ///
  /// Throws when the build is rejected, so a pipeline stops on an artifact
  /// nobody could have installed.
  Future<ImpaktfullAppstoreBuild> uploadToImpaktfullAppstore({
    required File file,
    required ImpaktfullAppstoreUploadConfig config,
  }) async {
    ImpaktfullCliLogger.setSpinnerPrefix('Impaktfull appstore upload');
    const uploadUtil = ImpaktfullAppstoreUploadUtil();
    final build = await uploadUtil.upload(file: file, config: config);

    ImpaktfullCliLogger.clearSpinnerPrefix();
    ImpaktfullCliLogger.logSeperator();
    ImpaktfullCliLogger.log(
      'Build ${build.versionLabel ?? build.id} is ready!!! 🎉🎉🎉',
    );
    // The LINK, so a pipeline log carries something somebody can click rather
    // than an id they would have to go and look up.
    final url = build.url;
    if (url != null) ImpaktfullCliLogger.log(url);
    ImpaktfullCliLogger.logSeperator();
    return build;
  }
}
