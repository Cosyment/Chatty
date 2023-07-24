import 'package:chatty/screens/conversation_screen.dart';
import 'package:chatty/util/platform_util.dart';
import 'package:flutter/material.dart';

import '../screens/tablet_screen.dart';

class Navigation {
  static navigator(BuildContext context, Widget page) {
    if (PlatformUtil.isMobile) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pushReplacement(_route(context, page));
      } else {
        Navigator.of(context).push(_route(context, page));
      }
    }
  }

  static _route(BuildContext context, Widget page) {
    // ConversationScreen conversation = context.widget as ConversationScreen;
    // conversation.
    return PageRouteBuilder(
        pageBuilder: (_, animation, __) => TabletScreenPage(sidebar: context.widget, body: page),
        transitionDuration: Duration.zero);
  }
}
