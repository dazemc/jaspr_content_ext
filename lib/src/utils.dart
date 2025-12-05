import 'package:jaspr_content/jaspr_content.dart';
import 'mermaid.dart';
import 'package:html/parser.dart' show parse;

Future<Node> processNode(
  Node node,
  String language,
  ComponentNode Function(Node node) function,
) async {
  switch (node) {
    case TextNode():
      break;
    case ElementNode():
      final first = node.children?.first;
      if (first is ElementNode) {
        if (first.attributes.containsValue(language)) {
          // _createMermaidNode(first);
          return function(first);
        }
      }
      break;
    case ComponentNode():
      break;
  }
  return node;
}

ComponentNode mermaidNode(Node node) {
  final mermaidString = _unescapeHtml(node.innerText);
  return ComponentNode(MermaidComponent(mermaidString: mermaidString));
}

//TODO:
// ComponentNode consoleNode(Node node) {
//   final consoleString = _unescapeHtml(node.innerText);
//   return ComponentNode(ConsoleComponent());
//   }

String _unescapeHtml(String htmlText) {
  final document = parse(htmlText);
  final String decoded = document.body?.text ?? document.text ?? "";
  return decoded;
}
