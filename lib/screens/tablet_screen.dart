import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class TabletScreenPage extends StatelessWidget {
  final Widget sidebar;
  final Widget body;
  final TabletMainView mainView;

  const TabletScreenPage({
    super.key,
    required this.sidebar,
    required this.body,
    this.mainView = TabletMainView.body
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (kIsWeb ||
            Platform.isWindows ||
            Platform.isMacOS ||
            Platform.isLinux) {
          return Row(
            children: [
              SizedBox(
                width: 300,
                child: sidebar,
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: body),
            ],
          );
        } else {
          return mainView == TabletMainView.body ? body : sidebar;
        }
      },
    );
  }
}

enum TabletMainView {
  sidebar,
  body
}