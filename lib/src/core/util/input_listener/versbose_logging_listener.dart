import 'dart:async';
import 'dart:io';

import 'package:impaktfull_cli/src/core/util/logger/logger.dart';

class VerboseLoggingListener {
  static StreamSubscription<List<int>>? _subscription;
  static var _cancelOnStop = true;
  static StreamController<String> streamController =
      StreamController.broadcast();

  VerboseLoggingListener._();

  static void startInputListener() {
    if (_subscription != null) return;
    _subscription = stdin.listen((data) {
      final input = String.fromCharCodes(data).trim();

      if (input.toLowerCase() == 'v' || input.toLowerCase() == 'verbose') {
        ImpaktfullCliLogger.enableVerbose(isVerboseLoggingEnabled: true);
      } else if (input.toLowerCase() == 'nv' ||
          input.toLowerCase() == 'no-verbose') {
        ImpaktfullCliLogger.enableVerbose(isVerboseLoggingEnabled: false);
      }
    });
  }

  static void stopListening() {
    if (!_cancelOnStop) return;
    _subscription?.cancel();
    _subscription = null;
  }

  static void setupMutiCommandInputListener() {
    _cancelOnStop = false;
  }

  static void clearMultipleCommandInputListener() {
    _cancelOnStop = true;
    stopListening();
    streamController.close();
  }
}
