import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CustomElementBuilder extends MarkdownElementBuilder {
  @override
  Widget text(MarkdownStyleSheet style, {required String text}) {
    return Text(text, style: const TextStyle(color: Colors.green));
  }
}
