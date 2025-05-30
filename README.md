# impaktfull_cli

## Disclaimer

**impaktfull_cli is still in unstable & untested. everything under <1.0.0 should not be used unless you want to test it**

## Usage

[![pub package](https://img.shields.io/pub/v/impaktfull_cli.svg)](https://pub.dartlang.org/packages/impaktfull_cli)
[![test](https://github.com/impaktfull/dart_impaktfull_cli/actions/workflows/test.yaml/badge.svg)](https://github.com/impaktfull/dart_impaktfull_cli/actions/workflows/test.yaml/badge.svg)
[![publish to github pages](https://github.com/impaktfull/dart_impaktfull_cli/actions/workflows/publish_to_githubpages.yaml/badge.svg)](https://github.com/impaktfull/dart_impaktfull_cli/actions/workflows/publish_to_githubpages.yaml/badge.svg)
[![live_demo](https://img.shields.io/badge/Live%20Demo-Available-7D64F2)](https://cli.impaktfull.com)

### ENV Variables:

#### impaktfull_cli ENV variabhles

- CI_KEYCHAIN_PASSWORD
- APPCENTER_OWNER_NAME
- APPCENTER_API_TOKEN
- APPLE_EMAIL
- APPLE_APP_SPECIFIC_PASSWORD
- GOOGLE_SERVICE_ACCOUNT_JSON_RAW

#### 3rth party ENV Variables

- OP_SERVICE_ACCOUNT_TOKEN

### Extend ImpaktfullCli

```dart
class TestCli extends ImpaktfullCli {
  //Add extra custom plugins heere
  @override
  Set<ImpaktfullPlugin> get plugins => {};

  @override
  Future<void> run(ImpaktfullCliRunner<TestCli> runner) => super.run(runner as ImpaktfullCliRunner<ImpaktfullCli>);
}
```

## Commands

### android

#### create_keychain

```bash
dart run impaktfull_cli android create_keychain
```

### apple

#### certificate

##### install

```bash
dart run impaktfull_cli apple certificate install
```

##### remove

```bash
dart run impaktfull_cli apple certificate remove
```

### ci_cd

#### report_status

```bash
dart run impaktfull_cli ci_cd report_status
```
