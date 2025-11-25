import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:syntax_highlight_lite/syntax_highlight_lite.dart';
import 'package:uuid/uuid.dart';

class MermaidRender {
  //TODO: hash/cache svg
  MermaidRender._();
  static final MermaidRender _instance = MermaidRender._();
  static const _command = 'mmdc';

  factory MermaidRender() {
    return _instance;
  }

  void subProcess(String mermaidString, String uuid) async {
    String svgDir = './images/mermaid/';
    if (!await File("index.html").exists()) {
      svgDir = './web/images/mermaid/';
    }
    final dir = Directory(svgDir);
    if (!await dir.exists()) {
      dir.create(recursive: true);
    }
    final List<String> arguments = <String>[
      '--input',
      '-',
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
    final String uuid = _fastHash(mermaidString).toString();
    print(uuid);
    print("MERMAID: Rendering svg elements");
    final String location = './images/mermaid/$uuid.svg';
    final File file = .new(location);
    print(file.path);
    if (file.existsSync()) {
      print("reusing mermaid svg: $uuid");
    } else {
      mermaidRender.subProcess(mermaidString, uuid);
    }
    print(location);

    // return pre(classes: ('mermaid'), [text(component.definition.toString())]);
    // TODO: make a better svg lib
    return img(src: location);
  }

  int _fastHash(String string) {
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
}
