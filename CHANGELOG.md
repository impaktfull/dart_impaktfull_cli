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
