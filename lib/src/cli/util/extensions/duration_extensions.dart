extension DurationExtensions on Duration {
  String get humanReadibleDuration {
    final minutesAndSeconds =
        '${inMinutes.remainder(60)}m ${(inSeconds.remainder(60))}s';
    if (inHours == 0) return minutesAndSeconds;
    return "${inHours}h $minutesAndSeconds";
  }
}
