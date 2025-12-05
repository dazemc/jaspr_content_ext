import 'package:jaspr_content/jaspr_content.dart';
import 'utils.dart' as util;

class ConsoleExtension extends PageExtension {
  ConsoleExtension();

  @override
  Future<List<Node>> apply(Page page, List<Node> nodes) async {
    return [
      for (final node in nodes)
        await util.processNode(node, 'language-console'),
    ];
  }
}
