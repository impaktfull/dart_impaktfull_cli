import 'dart:async';
import 'dart:io';

import 'package:impaktfull_cli/src/core/util/logger/logger.dart';

class VerboseLoggingListener {
  static StreamSubscription<List<int>>? _subscription;

  VerboseLoggingListener._();

  static void startInputListener() {
    _subscription = stdin.listen((data) {
      final input = String.fromCharCodes(data).trim();

      if (input.toLowerCase() == 'v' || input.toLowerCase() == 'verbose') {
        ImpaktfullCliLogger.enableVerbose(isVerboseLoggingEnabled: true);
      } else if (input.toLowerCase() == 'nv' || input.toLowerCase() == 'no-verbose') {
        ImpaktfullCliLogger.enableVerbose(isVerboseLoggingEnabled: false);
      }
    });
  }

  static void stopListening() => _subscription?.cancel();
}
