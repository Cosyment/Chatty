import 'package:chatty/screens/chat_screen.dart';
import 'package:chatty/util/navigation.dart';
import 'package:chatty/widgets/popup_box_constraints.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/models.dart';

class ConversationEditDialog extends StatefulWidget {
  final Conversation conversation;
  final bool isEdit;

  const ConversationEditDialog({required this.conversation, this.isEdit = false, super.key});

  @override
  State<ConversationEditDialog> createState() => _ConversationEditDialogState();
}

class _ConversationEditDialogState extends State<ConversationEditDialog> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _titleEditingController;
  late TextEditingController _systemMessageEditingController;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _titleEditingController = TextEditingController();
    _systemMessageEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _systemMessageEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _titleEditingController.text = widget.conversation.title;
    _systemMessageEditingController.text = widget.conversation.systemMessage;

    return AlertDialog(
      content: Container(
          constraints: PopupBoxConstraints.custom(),
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleEditingController,
                    // autofocus: true,
                    validator: (value) {
                      return value != null && value.isEmpty ? S.current.title_should_not_be_empty : null;
                    },
                    decoration: InputDecoration(hintText: S.current.enter_a_conversation_title),
                  ),
                  TextFormField(
                    controller: _systemMessageEditingController,
                    maxLines: 3,
                    decoration:
                        InputDecoration(hintText: '${S.current.message_to_help_set_the_behavior_of_the} ${S.current.appName}'),
                  ),
                ],
              ))),
      title: Text(widget.isEdit ? S.current.edit_conversation : S.current.new_conversation),
      actions: <Widget>[
        TextButton(
          child: Text(S.current.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(S.current.ok),
          onPressed: () {
            if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;
            widget.conversation.title = _titleEditingController.text;
            widget.conversation.systemMessage = _systemMessageEditingController.text;
            if (!widget.isEdit) {
              widget.conversation.lastUpdated = DateTime.now();
            }
            if (!widget.isEdit) {
              Navigation.navigator(context, ChatScreenPage(currentConversation: widget.conversation));
            }
            Navigator.of(context).pop(widget.conversation);
          },
        ),
      ],
    );
  }
}
