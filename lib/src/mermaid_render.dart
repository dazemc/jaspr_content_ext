import 'dart:io';
import 'package:jaspr/server.dart';

class MermaidRender {
  MermaidRender._();
  static final MermaidRender _instance = MermaidRender._();
  static const _command = 'mmdc';
  static const buildDir = 'build/jaspr/';

  factory MermaidRender() {
    return _instance;
  }

  void subProcess(String mermaidString, String uuid) async {
    late String svgDir;
    if (kDebugMode) {
      svgDir = './web/images/mermaid/';
    } else {
      Directory(buildDir).create(recursive: true);
      svgDir = '$buildDir/images/mermaid/';
    }
    final dir = Directory(svgDir);
    if (!await dir.exists()) {
      dir.create(recursive: true);
    }
    final List<String> arguments = <String>[
      '--input',
      '-',
      '-b',
      'transparent',
      '-o',
      '$svgDir$uuid.svg',
    ];
    final proc = await Process.start(_command, arguments);
    mermaidString
        .split('\n')
        .forEach((String line) => proc.stdin.writeln(line));
    proc.stdin.close();
  }
}

int fastHash(String string) {
  //https://pub.dev/documentation/logs_vault/latest/schemes_logs_vault/fastHash.html
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  // fit signed bit, keep lower 31 bits
  return hash & 0x7FFFFFFF;
}
