import 'package:chatty/widgets/popup_box_constraints.dart';
import 'package:chatty/widgets/theme_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;

  const ConfirmDialog({required this.title, required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Container(constraints: PopupBoxConstraints.custom(height: 45.0), child: Text(content)),
      actions: [
        TextButton(
          child: Text(S.current.cancel),
          onPressed: () => Navigator.pop(context, false),
        ),
        ElevatedButton(
          child: Text(S.current.ok),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
