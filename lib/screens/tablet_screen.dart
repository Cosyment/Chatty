import 'dart:ffi';

import 'package:chatty/bloc/blocs.dart';
import 'package:chatty/event/event_bus.dart';
import 'package:chatty/services/local_storage_service.dart';
import 'package:chatty/widgets/chat_screen_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../event/event_message.dart';
import '../services/chat_service.dart';
import '../util/platform_util.dart';

class TabletScreenPage extends StatefulWidget {
  final Widget sidebar;
  final Widget body;
  final TabletMainView mainView;

  const TabletScreenPage(
      {super.key,
      required this.sidebar,
      required this.body,
      this.mainView = TabletMainView.body});

  @override
  State<StatefulWidget> createState() => _TableScreenPage();
}

class _TableScreenPage extends State<TabletScreenPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    EventBus.getDefault().register<EventMessage<EventType>>(this, (event) {
      if (event.data == EventType.CLOSE_DRAWER) {
        scaffoldKey.currentState?.closeDrawer();
      }
    });
    super.initState();
  }

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
                width: PlatformUtil.isMobile ? 300 : 250,
                child: widget.sidebar,
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: widget.body),
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
                appBar: ChatScreenAppBar(currentConversation: conversation),
                key: scaffoldKey,
                drawer: Drawer(
                  //New added
                  width: 250.toDouble(),
                  child: widget.sidebar, //New added
                ),
                //New added
                body: Center(
                  child: widget.body,
                ),
              ));
        }
      },
    );
  }
}

enum TabletMainView { sidebar, body }
