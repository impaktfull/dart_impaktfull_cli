# 0.1.0

## Refactor:
- The plugins should be more flexible now. `ImpaktfullCli()` should be used as a starting point. 
  These methods should make it more clear how to use the plugins:
    - runWithPlugin<T>()
    - runWithCli()
    - getPlugin()

# 0.0.4

## Fixes:
- cleanup dependency injection with default implementations

# 0.0.3

## Fixes:
- removed xml dependency

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
