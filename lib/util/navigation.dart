import 'package:chatty/util/platform_util.dart';
import 'package:flutter/material.dart';

import '../screens/conversation_screen.dart';
import '../screens/tablet_screen.dart';

class Navigation {
  static navigator(BuildContext context, Widget page) {
    if (PlatformUtil.isMobile) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pushReplacement(_route(page));
      } else {
        Navigator.of(context).push(_route(page));
      }
    }
  }

  static _route(Widget page) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, _) => TabletScreenPage(
            sidebar: const ConversationScreen(
              selectedConversation: null,
            ),
            body: page),
        transitionDuration: Duration.zero);
  }
}
