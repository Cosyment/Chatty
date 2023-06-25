import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;

  const ConfirmDialog({
    required this.title,
    required this.content,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child:  Text(AppLocalizations.of(context)!.cancel),
          onPressed: () => Navigator.pop(context, false),
        ),
        ElevatedButton(
          child:  Text(AppLocalizations.of(context)!.ok),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}