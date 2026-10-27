import 'dart:io';

import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/util/process/process_runner.dart';
import 'package:impaktfull_cli/src/integrations/one_password/plugin/one_password_plugin.dart';
import 'package:test/test.dart';

class _FakeProcessRunner extends ProcessRunner {
  Map<String, String>? environment;
  bool? maskOutput;

  @override
  Future<String> runProcess(
    List<String> args, {
    Map<String, String>? environment,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
    bool maskOutput = false,
    bool maskErrorOutput = false,
  }) async {
    this.environment = environment;
    this.maskOutput = maskOutput;
    return 'value';
  }

  @override
  Future<void> requestSudo() async {}
}

void main() {
  group('OnePasswordPlugin', () {
    late _FakeProcessRunner processRunner;

    setUp(() => processRunner = _FakeProcessRunner());

    Future<Map<String, String>?> read({
      Map<String, String> environment = const {},
      Secret? rawServiceAccount,
    }) async {
      await OnePasswordPlugin(
        processRunner: processRunner,
        environment: environment,
      ).getOnePasswordField(
        vaultName: 'vault',
        opUuid: 'uuid',
        fieldName: 'password',
        rawServiceAccount: rawServiceAccount,
      );
      return processRunner.environment;
    }

    test('disables biometric unlock with a raw service account', () async {
      final environment = await read(rawServiceAccount: Secret('token'));
      expect(environment, {
        'OP_SERVICE_ACCOUNT_TOKEN': 'token',
        'OP_BIOMETRIC_UNLOCK_ENABLED': 'false',
      });
      expect(processRunner.maskOutput, isTrue);
    });

    test('disables biometric unlock with a token in the environment', () async {
      final environment = await read(
        environment: {'OP_SERVICE_ACCOUNT_TOKEN': 'token'},
      );
      expect(environment, {'OP_BIOMETRIC_UNLOCK_ENABLED': 'false'});
    });

    test('keeps the desktop app integration without a token', () async {
      expect(await read(), isEmpty);
      expect(
        await read(environment: {'OP_SERVICE_ACCOUNT_TOKEN': ''}),
        isEmpty,
      );
    });

    test('does not override an explicit OP_BIOMETRIC_UNLOCK_ENABLED', () async {
      final environment = await read(
        environment: {
          'OP_SERVICE_ACCOUNT_TOKEN': 'token',
          'OP_BIOMETRIC_UNLOCK_ENABLED': 'true',
        },
        rawServiceAccount: Secret('token'),
      );
      expect(environment, {'OP_SERVICE_ACCOUNT_TOKEN': 'token'});
    });
  });
}
