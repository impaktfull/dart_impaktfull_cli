import 'package:impaktfull_cli/impaktfull_cli.dart';

import 'example_config.dart';

Future<void> main(List<String> arguments) => ImpaktfullCli().run(
      (cli) =>
          cli.ciCdPlugin.startBuildWithCertificateAndPasswordFromOnePassword(
        opVaultName: ExampleConfig.onePasswordVaultName,
        opUuid: ExampleConfig.onePasswordUuid,
        keyChainName: ExampleConfig.keyChainName,
        globalKeyChainPassword: ExampleConfig.globalKeyChainPassword,
        onStartBuild: () => cli.ciCdPlugin.buildIos(),
      ),
    );
