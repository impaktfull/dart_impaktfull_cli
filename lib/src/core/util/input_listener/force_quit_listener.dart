import 'dart:async';
import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';

typedef AsyncCallback = Future<void> Function();

class ForceQuitListener {
  static var _isShuttingDown = false;
  static final _listeners = <AsyncCallback>{};

  static StreamSubscription<ProcessSignal>? _subscription;

  static void _addListener(AsyncCallback listener) => _listeners.add(listener);

  static void _removeListener(AsyncCallback listener) => _listeners.remove(listener);

  static void init() {
    _subscription = ProcessSignal.sigint.watch().listen((signal) async {
      if (_isShuttingDown) return;
      _isShuttingDown = true;
      ImpaktfullCliLogger.log('\nForce quit detected. Cleaning up...');
      ImpaktfullCliLogger.verbose('Cleaning up ${_listeners.length} listeners...');
      await Future.wait(_listeners.map((e) => e()));
      exit(0);
    });
  }

  static void stopListening() => _subscription?.cancel();

  static Future<void> catchForceQuit(
    AsyncCallback callback, {
    required AsyncCallback cleanup,
  }) async {
    try {
      _addListener(cleanup);
      await callback();
      _removeListener(cleanup);
    } catch (e) {
      rethrow;
    } finally {
      _removeListener(cleanup);
      await cleanup();
    }
  }
}
