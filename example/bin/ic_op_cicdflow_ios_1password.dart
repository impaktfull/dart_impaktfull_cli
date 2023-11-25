import 'package:impaktfull_cli/impaktfull_cli.dart';

import 'example_config.dart';

Future<void> main(List<String> arguments) =>
    ImpaktfullCli().runWithPlugin<CiCdPlugin>(
      (plugin) => plugin.startBuildWithCertificateAndPasswordFromOnePassword(
        opUuid: ExampleConfig.onePasswordUuid,
        keyChainName: ExampleConfig.keyChainName,
        globalKeyChainPassword: ExampleConfig.globalKeyChainPassword,
        onStartBuild: () => plugin.buildIos(),
      ),
    );
