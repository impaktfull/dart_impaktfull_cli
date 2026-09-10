/// A build, as the appstore reports it.
class ImpaktfullAppstoreBuild {
  final String id;

  /// `uploading`, `processing`, `ready` or `failed`. Switch on this, never on
  /// the failure message.
  final String status;

  /// `1.2.0 (44)`. Read out of the artifact by the server, so it is null until
  /// the build has been inspected.
  final String? versionLabel;

  /// The page a person opens. Printed on success, so a pipeline log carries a
  /// link somebody can click rather than an id they have to look up.
  final String? url;

  final ImpaktfullAppstoreBuildFailure? failure;

  const ImpaktfullAppstoreBuild({
    required this.id,
    required this.status,
    this.versionLabel,
    this.url,
    this.failure,
  });

  bool get isProcessing => status == 'processing' || status == 'uploading';

  bool get isReady => status == 'ready';

  bool get isFailed => status == 'failed';

  factory ImpaktfullAppstoreBuild.fromJson(
    Map<String, dynamic> json, {
    String? url,
  }) {
    final failure = json['failure'];
    return ImpaktfullAppstoreBuild(
      id: json['id'] as String,
      status: json['status'] as String,
      versionLabel: json['versionLabel'] as String?,
      url: url,
      failure: failure is Map<String, dynamic>
          ? ImpaktfullAppstoreBuildFailure.fromJson(failure)
          : null,
    );
  }
}

/// Why a build did not become installable.
class ImpaktfullAppstoreBuildFailure {
  /// The stable code, for a pipeline that wants to branch on it.
  final String code;

  /// A sentence written for a person, already localised by the server.
  final String message;

  /// What the inspector filled in for the placeholders, when there was any.
  final String? detail;

  const ImpaktfullAppstoreBuildFailure({
    required this.code,
    required this.message,
    this.detail,
  });

  factory ImpaktfullAppstoreBuildFailure.fromJson(Map<String, dynamic> json) =>
      ImpaktfullAppstoreBuildFailure(
        code: json['code'] as String,
        message: json['message'] as String,
        detail: json['detail'] as String?,
      );

  @override
  String toString() =>
      detail == null ? '$message ($code)' : '$message ($code): $detail';
}

/// One environment an upload key may write to.
class ImpaktfullAppstoreEnvironment {
  final String id;

  /// `ios` or `android`.
  final String platform;

  /// `staging`, `acceptance`, `production`.
  final String name;

  /// `iOS · staging`, built server-side so nothing renders it twice.
  final String label;

  final String appIdentifier;

  const ImpaktfullAppstoreEnvironment({
    required this.id,
    required this.platform,
    required this.name,
    required this.label,
    required this.appIdentifier,
  });

  factory ImpaktfullAppstoreEnvironment.fromJson(Map<String, dynamic> json) =>
      ImpaktfullAppstoreEnvironment(
        id: json['id'] as String,
        platform: json['platform'] as String,
        name: json['name'] as String,
        label: json['label'] as String,
        appIdentifier: json['appIdentifier'] as String,
      );
}

/// The app an upload key belongs to, and the environments it may write to.
class ImpaktfullAppstoreApp {
  final String id;
  final String name;
  final List<ImpaktfullAppstoreEnvironment> environments;

  const ImpaktfullAppstoreApp({
    required this.id,
    required this.name,
    required this.environments,
  });

  factory ImpaktfullAppstoreApp.fromJson(Map<String, dynamic> json) {
    final app = json['app'] as Map<String, dynamic>;
    final environments = (json['environments'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ImpaktfullAppstoreEnvironment.fromJson)
        .toList();
    return ImpaktfullAppstoreApp(
      id: app['id'] as String,
      name: app['name'] as String,
      environments: environments,
    );
  }
}
