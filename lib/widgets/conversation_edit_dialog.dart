import 'package:flutter/material.dart';

import '../models/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConversationEditDialog extends StatefulWidget {
  final Conversation conversation;
  final bool isEdit;

  const ConversationEditDialog(
      {required this.conversation, this.isEdit = false, super.key});

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
      content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleEditingController,
                validator: (value) {
                  return value != null && value.isEmpty
                      ? AppLocalizations.of(context)!.title_should_not_be_empty
                      : null;
                },
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!
                        .enter_a_conversation_title),
              ),
              TextFormField(
                controller: _systemMessageEditingController,
                maxLines: 3,
                decoration: InputDecoration(
                    hintText:
                        '${AppLocalizations.of(context)!.message_to_help_set_the_behavior_of_the} ${AppLocalizations.of(context)!.appName}'),
              ),
            ],
          )),
      title: Text(widget.isEdit
          ? AppLocalizations.of(context)!.edit_conversation
          : AppLocalizations.of(context)!.new_conversation),
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(AppLocalizations.of(context)!.ok),
          onPressed: () {
            if (_formKey.currentState == null ||
                !_formKey.currentState!.validate()) return;
            widget.conversation.title = _titleEditingController.text;
            widget.conversation.systemMessage =
                _systemMessageEditingController.text;
            if (!widget.isEdit) {
              widget.conversation.lastUpdated = DateTime.now();
            }
            Navigator.of(context).pop(widget.conversation);
          },
        ),
      ],
    );
  }
}
