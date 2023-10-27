import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import 'markdown/custom _markdown_widget.dart';

class ChatMessageWidget extends StatefulWidget {
  final ConversationMessage message;
  final bool isMarkdown;

  const ChatMessageWidget({super.key, required this.message, this.isMarkdown = true});

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  final bool _showContextMenu = false;

  @override
  Widget build(BuildContext context) {
    var isUser = widget.message.role == 'user';
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        margin: const EdgeInsets.all(1),
        // color: Color.lerp(Theme.of(context).colorScheme.background.withOpacity(.2), Colors.white, isUser ? 0.1 : 0.2),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isUser ? const SizedBox() : itemUser(),
            const SizedBox(width: 5),
            Expanded(
              child: Container(
                  padding: const EdgeInsets.only(left: 5, top: 4, right: 5, bottom: 10),
                  // color: Color.lerp(Theme.of(context).colorScheme.background.withOpacity(.2), Colors.white, isUser ? 0.1 : 0.2),
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  decoration: BoxDecoration(
                    // color: Color.lerp(ThemeColor.backgroundColor.withOpacity(.2), Colors.white, 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: widget.isMarkdown
                      ?
                      // MarkdownBody(data: widget.message.content)
                      CustomMarkdownWidget(
                          markdownData: widget.message.content,
                        )
                      : SelectableText(widget.message.content, style: TextStyle(color: Colors.white70))),
            ),
            isUser ? itemUser() : const SizedBox(),
          ],
        ));
  }

  Widget itemUser() {
    return GestureDetector(
      onTap: () {
        setState(() {
          // _showContextMenu = !_showContextMenu;
        });
      },
      child: SizedBox(
        width: 32,
        height: 32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.message.role == 'user' ? Icons.account_circle : Icons.smart_toy, size: 32),
            if (_showContextMenu) const SizedBox(height: 16),
            if (_showContextMenu)
              IconButton(
                  icon: const Icon(Icons.content_copy, size: 20),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: widget.message.content));
                  })
          ],
        ),
      ),
    );
  }
}
