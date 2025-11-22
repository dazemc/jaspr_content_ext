import 'mermaid.dart';

const String _test = '''    graph TD
    A[Client] --> B[Load Balancer]
    B --> C[Server]
    C --> D[Database]
''';

Future<void> main() async {
  final MermaidRender mermaidRender = .new();
  mermaidRender.subProcess(_test);
}
