import 'dart:io';

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:xml/xml.dart';
import 'mermaid_render.dart';
import 'utils.dart' as util;

class MermaidExtension extends PageExtension {
  MermaidExtension();

  @override
  Future<List<Node>> apply(Page page, List<Node> nodes) async {
    return [
      for (final node in nodes)
        await util.processNode(node, 'language-mermaid', util.mermaidNode),
    ];
  }
}

class MermaidComponent extends AsyncStatelessComponent {
  final String mermaidString;
  const MermaidComponent({super.key, required this.mermaidString});
  @override
  Future<Component> build(BuildContext context) async {
    final MermaidRender mermaidRender = .new();
    final String uuid = fastHash(mermaidString).toString();
    final String svgDir = 'images/mermaid/$uuid.svg';
    final File file = kDebugMode ? .new('./web/$svgDir') : .new(svgDir);
    if (!await file.exists()) {
      mermaidRender.subProcess(mermaidString, uuid);
    }
    return img(src: svgDir);
    //TODO: return svg
    final component = await _loadSvg(file);
    if (component != null) {
      // return component;
    } else {
      return Component.text(
        "Error processing svg file for mermaid diagram: $uuid\n$mermaidString",
      );
    }
  }

  Future<Component?> _loadSvg(File file) async {
    final svgContent = await file.readAsString();
    final document = XmlDocument.parse(svgContent);
    final svgElement = document.findAllElements('svg').first;
    // final width = svgElement.getAttribute('width');
    // final height = svgElement.getAttribute('height');
    final viewBox = svgElement.getAttribute('viewBox');
    final attributes = <String, String>{};

    for (final attr in svgElement.attributes) {
      if (!["width", "height", "viewBox"].contains(attr.name.local)) {
        attributes[attr.name.local] = attr.value;
      }
    }

    return svg(
      width: Unit.percent(100),
      height: Unit.percent(100),
      viewBox: viewBox,
      attributes: attributes,
      [],
    );
  }
}
