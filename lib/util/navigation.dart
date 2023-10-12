import 'package:chatty/models/conversation.dart';
import 'package:chatty/screens/screens.dart';
import 'package:chatty/services/chat_service.dart';
import 'package:chatty/util/platform_util.dart';
import 'package:chatty/widgets/common_stateful_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../event/event_bus.dart';
import '../event/event_message.dart';

class Navigation {
  static navigator(BuildContext context, CommonStatefulWidget page) {
    if (PlatformUtil.isMobile) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    } else {
      // if (Navigator.of(context).canPop()) {
      //   Navigator.of(context).pushReplacement(_route(context, page));
      // } else {
      //   Navigator.of(context).push(_route(context, page));
      // }
      EventBus.getDefault().post(EventMessage<CommonStatefulWidget>(page));
    }
  }

  static navigatorChat(BuildContext context, ChatService chatService, Conversation conversation) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BlocProvider(
            create: (context) => ChatBloc(chatService: chatService, initialConversation: conversation),
            child: ChatScreenPage(currentConversation: conversation))));
  }

  static _route(BuildContext context, CommonStatefulWidget page) {
    return PageRouteBuilder(
        pageBuilder: (_, animation, __) => TabletScreenPage(sidebar: context.widget, body: page),
        transitionDuration: Duration.zero);
  }
}
