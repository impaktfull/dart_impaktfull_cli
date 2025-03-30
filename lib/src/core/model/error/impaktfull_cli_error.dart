class ImpaktfullCliError extends Error {
  final String message;

  ImpaktfullCliError(this.message);

  @override
  String toString() => 'ImpaktfullCliError: $message';
}
