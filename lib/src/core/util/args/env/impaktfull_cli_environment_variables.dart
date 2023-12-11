import 'dart:io';

import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';

class ImpaktfullCliEnvironmentVariables {
  static const _envKeyCiKeyChainPassword = 'CI_KEYCHAIN_PASSWORD';
  static const _envKeyAppCenterOwnerName = 'APPCENTER_OWNER_NAME';
  static const _envKeyAppCenterToken = 'APPCENTER_API_TOKEN';
  static const _envKeyAppleEmail = 'APPLE_EMAIL';
  static const _envKeyAppleAppSpecificPassword = 'APPLE_APP_SPECIFIC_PASSWORD';
  static const _envKeyGoogleServiceAccountJsonRaw = 'GOOGLE_SERVICE_ACCOUNT_JSON_RAW';
  static const envKeyOnePasswordAccountToken = 'OP_SERVICE_ACCOUNT_TOKEN';

  static const _initEnvKyes = [
    _envKeyCiKeyChainPassword,
    _envKeyAppCenterOwnerName,
    _envKeyAppCenterToken,
    _envKeyAppleEmail,
    _envKeyAppleAppSpecificPassword,
    _envKeyGoogleServiceAccountJsonRaw,
    envKeyOnePasswordAccountToken,
  ];

  const ImpaktfullCliEnvironmentVariables._();

  static void initSecrets() {
    for (final key in _initEnvKyes) {
      _getEnvVariableSecret(key);
    }
  }

  static String? _getEnvVariable(String key) {
    final envVariables = Platform.environment;
    if (envVariables.containsKey(key)) return envVariables[key];
    return null;
  }

  static String _getNonOptionalEnvVariable(String key) {
    final value = _getEnvVariable(key);
    if (value == null) {
      throw ImpaktfullCliError('$key env variable is not set');
    }
    return value;
  }

  static Secret? _getEnvVariableSecret(String key) {
    final value = _getEnvVariable(key);
    if (value == null) return null;
    return Secret(value);
  }

  static Secret _getNonOptionalEnvVariableSecret(String key) {
    final value = _getEnvVariableSecret(key);
    if (value == null) {
      throw ImpaktfullCliError('$key env variable is not set.');
    }
    return value;
  }

  static Secret? _getUnlockKeyChainPassword() => _getEnvVariableSecret(_envKeyCiKeyChainPassword);

  static Secret? _getAppCenterToken() => _getEnvVariableSecret(_envKeyAppCenterToken);

  static String getAppCenterOwnerName() => _getNonOptionalEnvVariable(_envKeyAppCenterOwnerName);

  static Secret getUnlockKeyChainPassword() {
    final secret = _getUnlockKeyChainPassword();
    if (secret == null) {
      throw ImpaktfullCliError('$_envKeyCiKeyChainPassword env variable is not set');
    }
    return secret;
  }

  static Secret getAppCenterToken() {
    final secret = _getAppCenterToken();
    if (secret == null) {
      throw ImpaktfullCliError('$_envKeyAppCenterToken env variable is not set');
    }
    return secret;
  }

  static String getAppleEmail() => _getNonOptionalEnvVariable(_envKeyAppleEmail);

  static Secret getAppleAppSpecificPassword() => _getNonOptionalEnvVariableSecret(_envKeyAppleAppSpecificPassword);

  static Secret getGoogleServiceAccountCredentials() => _getNonOptionalEnvVariableSecret(_envKeyGoogleServiceAccountJsonRaw);
}
