import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:syntax_highlight_lite/syntax_highlight_lite.dart';

class MermaidRender {
  //TODO: hash/cache svg
  MermaidRender._();
  static final MermaidRender _instance = MermaidRender._();
  static const _command = 'mmdc';
  static const _arguments = <String>[
    '--input',
    '-',
    '-o',
    './web/images/out.svg',
  ];
  late String svg;

  factory MermaidRender() {
    return _instance;
  }

  void subProcess(String mermaidString) async {
    final proc = await Process.start(_command, _arguments);
    mermaidString
        .split('\n')
        .forEach((String line) => proc.stdin.writeln(line));
    proc.stdin.close();
  }
}

class MermaidBlock extends CustomComponent {
  MermaidBlock({
    this.defaultLanguage = 'mermaid',
    this.grammars = const {},
    this.codeTheme,
  }) : super.base();

  static Component from({required String source, Key? key}) {
    return MermaidStaticComponent(key: key, mermaidString: 'test');
  }

  /// The default language for the code block.
  final String defaultLanguage;

  /// The available grammars for the code block.
  ///
  /// The key is the name of the language.
  /// The value is a json encoded string of the grammar.
  final Map<String, String> grammars;

  /// The default theme for the code block.
  final HighlighterTheme? codeTheme;

  bool _initialized = false;
  HighlighterTheme? _defaultTheme;

  @override
  Component? create(Node node, NodesBuilder builder) {
    if (node case ElementNode(tag: 'mermaid')) {
      return AsyncBuilder(
        builder: (context) async {
          return MermaidStaticComponent(mermaidString: node.innerText);
        },
      );
    }
    return null;
  }
}

class MermaidBlockSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^```mermaid\s*$');

  @override
  bool canParse(md.BlockParser parser) {
    return pattern.hasMatch(parser.current.content);
  }

  @override
  md.Node parse(md.BlockParser parser) {
    parser.advance();

    final buffer = StringBuffer();

    // Collect lines until ```
    while (!parser.isDone && !parser.current.content.startsWith('```')) {
      buffer.writeln(parser.current.content);
      parser.advance();
    }

    if (!parser.isDone) parser.advance();

    return md.Element('mermaid', [md.Text(buffer.toString().trim())])
      ..attributes['definition'] = buffer.toString().trim();
  }
}

class MermaidParser extends MarkdownParser {
  const MermaidParser();

  @override
  DocumentBuilder get documentBuilder => (Page page) {
    return md.Document(
      blockSyntaxes: [
        ...MarkdownParser.defaultBlockSyntaxes,
        MermaidBlockSyntax(),
      ],
    );
  };
}

class MermaidStaticComponent extends StatelessComponent {
  final String mermaidString;
  const MermaidStaticComponent({super.key, required this.mermaidString});
  @override
  Component build(BuildContext context) {
    final MermaidRender mermaidRender = .new();
    print("MERMAID: $mermaidString\n\n");
    print("MERMAID: Rendering svg elements");
    mermaidRender.subProcess(mermaidString);
    // return pre(classes: ('mermaid'), [text(component.definition.toString())]);
    // TODO: make a better svg lib
    return img(src: './images/out.svg');

    return text(mermaidString);
  }
}
