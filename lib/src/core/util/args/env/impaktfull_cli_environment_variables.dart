import 'dart:io';

import 'package:impaktfull_cli/src/core/model/data/secret.dart';
import 'package:impaktfull_cli/src/core/model/error/impaktfull_cli_error.dart';

class ImpaktfullCliEnvironmentVariables {
  static const _envKeyCiKeyChainPassword = 'CI_KEYCHAIN_PASSWORD';
  static const _envKeyAppCenterOwnerName = 'APPCENTER_OWNER_NAME';
  static const _envKeyAppCenterToken = 'APPCENTER_API_TOKEN';
  static const _envKeyAppleEmail = 'APPLE_EMAIL';
  static const _envKeyAppleAppSpecificPassword = 'APPLE_APP_SPECIFIC_PASSWORD';
  static const _envKeyGoogleServiceAccountJsonRaw =
      'GOOGLE_SERVICE_ACCOUNT_JSON_RAW';
  static const envKeyOnePasswordAccountToken = 'OP_SERVICE_ACCOUNT_TOKEN';
  static const _envKeySlackBotToken = 'SLACK_BOT_TOKEN';
  static const envKeySlackSendMessageChannel = 'SLACK_SEND_MESSAGE_CHANNEL';
  static const envKeyGithubBuildNr = 'GITHUB_RUN_NUMBER';

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

  static String _getRequiredEnvVariable(String key) {
    final value = _getEnvVariable(key);
    if (value == null) {
      throw ImpaktfullCliError('$key env variable is not set');
    } else if (value.isEmpty) {
      throw ImpaktfullCliError('$key env variable is empty');
    }
    return value;
  }

  static Secret? _getEnvVariableSecret(String key) {
    final value = _getEnvVariable(key);
    if (value == null) return null;
    return Secret(value);
  }

  static Secret _getRequiredEnvVariableSecret(String key) {
    final value = _getEnvVariableSecret(key);
    if (value == null) {
      throw ImpaktfullCliError('$key env variable is not set.');
    }
    return value;
  }

  static Secret? _getUnlockKeyChainPassword() =>
      _getEnvVariableSecret(_envKeyCiKeyChainPassword);

  static Secret? _getAppCenterToken() =>
      _getEnvVariableSecret(_envKeyAppCenterToken);

  static String getAppCenterOwnerName() =>
      _getRequiredEnvVariable(_envKeyAppCenterOwnerName);

  static Secret getUnlockKeyChainPassword() {
    final secret = _getUnlockKeyChainPassword();
    if (secret == null) {
      throw ImpaktfullCliError(
          '$_envKeyCiKeyChainPassword env variable is not set');
    }
    return secret;
  }

  static Secret getAppCenterToken() {
    final secret = _getAppCenterToken();
    if (secret == null) {
      throw ImpaktfullCliError(
          '$_envKeyAppCenterToken env variable is not set');
    }
    return secret;
  }

  static String getAppleEmail() => _getRequiredEnvVariable(_envKeyAppleEmail);

  static Secret getAppleAppSpecificPassword() =>
      _getRequiredEnvVariableSecret(_envKeyAppleAppSpecificPassword);

  static Secret getGoogleServiceAccountCredentials() =>
      _getRequiredEnvVariableSecret(_envKeyGoogleServiceAccountJsonRaw);

  static Secret getSlackBotToken() =>
      _getRequiredEnvVariableSecret(_envKeySlackBotToken);

  static String getSlackSendMessageChannel() =>
      _getRequiredEnvVariable(envKeySlackSendMessageChannel);

  static String getGithubBuildNr() =>
      _getRequiredEnvVariable(envKeyGithubBuildNr);

  static String getEnvVariable(String envVariable) =>
      _getRequiredEnvVariable(envVariable);

  static Secret getEnvVariableSecret(String envVariable) =>
      _getRequiredEnvVariableSecret(envVariable);

  static Secret? getOptionalEnvVariableSecret(String envVariable) =>
      _getEnvVariableSecret(envVariable);
}
