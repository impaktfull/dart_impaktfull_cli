import 'dart:io';

/// Where a build came from: the commit, the branch, and the pipeline run.
///
/// Shown on the build page, so somebody looking at a build that misbehaves can
/// get to the code and the log that produced it without asking who uploaded it.
class ImpaktfullAppstoreCiMetadata {
  final String? commitSha;
  final String? branch;
  final String? runUrl;

  const ImpaktfullAppstoreCiMetadata({
    this.commitSha,
    this.branch,
    this.runUrl,
  });

  bool get isEmpty => commitSha == null && branch == null && runUrl == null;

  /// Reads what the CI provider already put in the environment.
  ///
  /// Only providers whose variables are unambiguous. Guessing from a variable
  /// that means something else elsewhere would put a wrong commit on a build
  /// page, and a wrong answer there is worse than no answer: somebody would go
  /// and read the wrong diff.
  factory ImpaktfullAppstoreCiMetadata.fromEnvironment() {
    final env = Platform.environment;

    if (env['GITHUB_ACTIONS'] == 'true') {
      final server = env['GITHUB_SERVER_URL'];
      final repository = env['GITHUB_REPOSITORY'];
      final runId = env['GITHUB_RUN_ID'];
      return ImpaktfullAppstoreCiMetadata(
        commitSha: env['GITHUB_SHA'],
        // `GITHUB_REF_NAME` is the branch on a push and the PR NUMBER on a
        // pull_request, where `GITHUB_HEAD_REF` is the branch. Preferring the
        // head ref means a build from a PR says which branch it came from
        // rather than saying "42".
        branch: env['GITHUB_HEAD_REF']?.isNotEmpty == true
            ? env['GITHUB_HEAD_REF']
            : env['GITHUB_REF_NAME'],
        runUrl: server != null && repository != null && runId != null
            ? '$server/$repository/actions/runs/$runId'
            : null,
      );
    }

    if (env['GITLAB_CI'] == 'true') {
      return ImpaktfullAppstoreCiMetadata(
        commitSha: env['CI_COMMIT_SHA'],
        branch: env['CI_COMMIT_REF_NAME'],
        runUrl: env['CI_JOB_URL'],
      );
    }

    if (env['CIRCLECI'] == 'true') {
      return ImpaktfullAppstoreCiMetadata(
        commitSha: env['CIRCLE_SHA1'],
        branch: env['CIRCLE_BRANCH'],
        runUrl: env['CIRCLE_BUILD_URL'],
      );
    }

    if (env['BITRISE_IO'] == 'true') {
      return ImpaktfullAppstoreCiMetadata(
        commitSha: env['BITRISE_GIT_COMMIT'],
        branch: env['BITRISE_GIT_BRANCH'],
        runUrl: env['BITRISE_BUILD_URL'],
      );
    }

    return const ImpaktfullAppstoreCiMetadata();
  }

  Map<String, dynamic> toJson() => {
        if (commitSha != null) 'commitSha': commitSha,
        if (branch != null) 'branch': branch,
        if (runUrl != null) 'runUrl': runUrl,
      };
}
