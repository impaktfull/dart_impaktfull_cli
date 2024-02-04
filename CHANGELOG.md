# 0.10.13

# Feat:
- Add the option to check if git is clean
- Add the option to versionbump using `release_config.json` file
- Add the option to check if a clitool is installed

# 0.10.12

# Fix:
- Cleanup keychain plugin after force quit

# 0.10.7 - 0.10.11

# Fix:
- Setting default keychain to newly created on in ci/cd plugin

# 0.10.6

# Fix:
- Keychain should be accessible to all from ci/cd plugin

# 0.10.5

# Fix:
- First check if new keychain already exists before creating a new one

# 0.10.4

# Fix:
- Delete build/ios/ipa folder before iOS build

# 0.10.3

# Fix:
- Keychain creation on macOS

# 0.10.2

# Fix:
- Renamed `valultName` to `opValueName` on `startBuildWithCertificateAndPasswordFromOnePassword` on the `CiCdPlugin`

# 0.10.1

# Fix:
- Export `valultName` for `startBuildWithCertificateAndPasswordFromOnePassword` on the `CiCdPlugin`

# 0.10.0

# Feat:
- Added `rawServiceAccount` to `startBuildWithCertificateAndPasswordFromOnePassword` on the `CiCdPlugin`

# 0.9.1

# Fix:
- Bug when downloading files using `OnePasswordPlugin`

# 0.9.0

# Feat:
- Export enable logging

# 0.8.0

# Feat:
- Pass service accounts to override the default service account in the `OnePasswordPlugin`

# 0.7.1

# Fix:
- Typo in `getServiceAccountCredentials`

# 0.7.0

# Feat:
- Added `getServiceAccountCredentials` to `OnePasswordPlugin` to get google service account credentials from 1password.

# 0.6.1

# Fix:
- Typo with `getTestFlightCredentials` in `OnePasswordPlugin`

# 0.6.0

# Feat:
- Better config for testflight upload

# 0.5.1 - 0.5.3

# Fix:
- Bug where testflight upload would succeed when the app was invalid because of a lower,same version number

# 0.5.0

# Feat:
- `PlaystoreUploadConfig` will default to `android/playstore_credentials.json`

# 0.4.0

# Feat:
- Export `joinPath` which is just an alternative for `join` from `path` package.

# 0.3.3

## Docs:
- `PlayStoreUploadConfig` extra documentation
- `TestflightUploadConfig` extra documentation

# 0.3.2

## Fix:
- `PlayStoreUploadConfig` required fields if needed
- `TestflightUploadConfig` required fields if needed

# 0.3.1

## Fix:
- Export `PlayStoreUploadConfig`
- Export `TestflightUploadConfig`

# 0.3.0

## Feat:
- (ci/cd): Upload to playstore with ci/cd plugin
- (ci/cd): Upload to appstore with ci/cd plugin

# 0.2.3 -> 0.2.20

## Features:
- (ci): Automatic publish to pub.dev from github actions (some trial and error happened)

# 0.2.2

## Features:
- (ci): Added ci to publish to pub.dev

# 0.2.1

## Features:
- (AppCenter): Export default distribution group.
- (cli): Added support to extend the cli with custom plugins.

# 0.2.0

## Rafactor:
- Rafactor to a setup where it is clear which plugins are available to use.

# 0.1.1

## Fixes:
- Export all required files.

# 0.1.0

## Refactor:
- The plugins should be more flexible now. `ImpaktfullCli()` should be used as a starting point. 
  These methods should make it more clear how to use the plugins:
    - runWithPlugin<T>()
    - runWithCli()
    - getPlugin()

# 0.0.4

## Fixes:
- cleanup dependency injection with default implementations.

# 0.0.3

## Fixes:
- Removed xml dependency.

# 0.0.2

## Fixes:
- Typo in `EmptyCommandConfig`
- meta version set to 1.1.0

# 0.0.1

## Features:
- Unstable initial version.
- Support for:
    - build flutter app
    - upload ipa to appcenter
    - upload apk to appcenter
    - upload api to testflight
    - upload apk to playstore
    - upload aab to playstore
    - create keychain
    - read from 1password with service account
