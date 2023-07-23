import 'package:chatbotty/bloc/blocs.dart';
import 'package:chatbotty/services/local_storage_service.dart';
import 'package:chatbotty/widgets/chat_screen_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/chat_service.dart';
import '../util/platform_util.dart';
import '../widgets/theme_color.dart';

class TabletScreenPage extends StatelessWidget {
  final Widget sidebar;
  final Widget body;
  final TabletMainView mainView;

  const TabletScreenPage({super.key,
    required this.sidebar,
    required this.body,
    this.mainView = TabletMainView.body});

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var conversation = chatService
        .getConversationById(LocalStorageService().currentConversationId);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!PlatformUtil.isMobile) {
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
          // return mainView == TabletMainView.body ? body : sidebar;
          return BlocProvider(
              create: (context) =>
              ConversationsBloc(chatService: context.read<ChatService>())
                ..add(const ConversationsRequested()),
              child:
              //手机端增加appbar
              Scaffold(
                appBar: ChatScreenAppBar(
                    currentConversation: conversation),
                drawer: Drawer(
                  //New added
                  width: 250.toDouble(),
                  child: sidebar, //New added
                ),
                //New added
                body: Center(
                  child: body,
                ),
              ));
        }
      },
    );
  }
}

enum TabletMainView { sidebar, body }
