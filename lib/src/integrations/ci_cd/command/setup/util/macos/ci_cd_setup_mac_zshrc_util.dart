import 'dart:io';

import 'package:impaktfull_cli/impaktfull_cli.dart';
import 'package:path/path.dart';

class CiCdSetupMacZshrcUtil {
  static const String impaktfullZshrcFile = "";
  static const String zshrcFile = "";

  final ProcessRunner processRunner;

  CiCdSetupMacZshrcUtil({
    required this.processRunner,
  });

  Future<void> addToZshrc(String comments, String content) async {
    final zshrcFile = _getImpaktfullZshrcFile();
    if (!zshrcFile.existsSync()) {
      zshrcFile.createSync(recursive: true);
    }
    final commentLine = "#$comments";
    final newLines = content.split('\n').map((e) => e.trim());
    final linesToAdd = <String>[];
    final zshrcLines = zshrcFile.readAsLinesSync();
    for (final zshrcLine in zshrcLines) {
      if (zshrcLine == commentLine) {
        continue;
      }
      if (newLines.contains(zshrcLine)) {
        continue;
      }
      linesToAdd.add(zshrcLine);
    }
    if (linesToAdd.isEmpty) {
      await addImpaktfullZshrcToZshrc();
      return;
    }
    final newContent = [
      commentLine,
      ...linesToAdd,
    ].join('\n');
    zshrcFile.writeAsStringSync(
      "$newContent\n",
      mode: FileMode.append,
    );
    await addImpaktfullZshrcToZshrc();
  }

  Future<void> addImpaktfullZshrcToZshrc() async {
    final zshrcFile = _getZshrcFile();
    final impaktfullZshrcFile = _getImpaktfullZshrcFile();
    if (!impaktfullZshrcFile.existsSync()) {
      return;
    }
    final zshrcContent = zshrcFile.readAsStringSync();
    final sourceImpaktfullZshrc = r'source $HOME/.zshrc-impaktfull-cli';
    if (zshrcContent.contains(sourceImpaktfullZshrc)) {
      return;
    }
    zshrcFile.writeAsStringSync(
      "$sourceImpaktfullZshrc\n",
      mode: FileMode.append,
    );
    await _reloadZshrc();
  }

  File _getZshrcFile() {
    final home = ImpaktfullCliEnvironmentVariables.getEnvVariable("HOME");
    final fileName = '.zshrc';
    return File(join(home, fileName));
  }

  File _getImpaktfullZshrcFile() {
    final home = ImpaktfullCliEnvironmentVariables.getEnvVariable("HOME");
    return File(join(home, '.impaktfull', 'impaktfull_cli', '.zshrc'));
  }

  Future<void> _reloadZshrc() async {
    final zshrcFile = _getZshrcFile();
    await processRunner.runProcess(
      [
        '/bin/zsh',
        '-c',
        'source ${zshrcFile.path}',
      ],
      runInShell: true,
    );
  }

  Future<void> validateZshrc() async {
    final zshrcFile = _getZshrcFile();
    if (!zshrcFile.existsSync()) {
      throw ImpaktfullCliError(
          "Zshrc not found, install zsh first and try again");
    }
  }
}
