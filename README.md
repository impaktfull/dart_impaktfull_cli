# impaktfull_cli

**impaktfull_cli is still in unstable & untested. everything under <1.0.0 should not be used unless you want to test the cli**

## Usage

[![pub package](https://img.shields.io/pub/v/impaktfull_cli.svg)](https://pub.dartlang.org/packages/impaktfull_cli)

## ENV Variables:

### impaktfull_cli ENV variabhles

- CI_KEYCHAIN_PASSWORD
- APPCENTER_OWNER_NAME
- APPCENTER_API_TOKEN
- APPLE_EMAIL
- APPLE_APP_SPECIFIC_PASSWORD
- GOOGLE_SERVICE_ACCOUNT_JSON_RAW

### 3rth party ENV Variables

- OP_SERVICE_ACCOUNT_TOKEN

## Extend ImpaktfullCli

```dart
class TestCli extends ImpaktfullCli {
  //Add extra custom plugins heere
  @override
  Set<ImpaktfullPlugin> get plugins => {};

  @override
  Future<void> run(ImpaktfullCliRunner<TestCli> runner) => super.run(runner as ImpaktfullCliRunner<ImpaktfullCli>);
}
```