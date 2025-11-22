import 'dart:io';

const String _test = '''    graph TD
    A[Client] --> B[Load Balancer]
    B --> C[Server]
    C --> D[Database]
''';

Future<void> main() async {
  final MermaidRender mermaidRender = .new();
  mermaidRender.subProcess(_test);
}

class MermaidRender {
  const MermaidRender();
  static const _command = 'mmdc';
  static const _arguments = <String>['--input', '-'];

  void subProcess(String mermaidString) async {
    final proc = await Process.start(_command, _arguments);
    mermaidString
        .split('\n')
        .forEach((String line) => proc.stdin.writeln(line));
    proc.stdin.close();
  }
}
