import 'package:chatty/bloc/blocs.dart';
import 'package:chatty/event/event_bus.dart';
import 'package:chatty/services/local_storage_service.dart';
import 'package:chatty/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../event/event_message.dart';
import '../generated/l10n.dart';
import '../services/chat_service.dart';
import '../util/platform_util.dart';
import '../widgets/common_stateful_widget.dart';

class TabletScreenPage extends StatefulWidget {
  final Widget sidebar;
  final Widget body;
  final TabletMainView mainView;

  const TabletScreenPage({super.key, required this.sidebar, required this.body, this.mainView = TabletMainView.body});

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

    EventBus.getDefault().register<EventMessage<CommonStatefulWidget>>(this, (event) {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var conversation = chatService.getConversationById(LocalStorageService().currentConversationId);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!PlatformUtil.isMobile) {
          return Row(
            children: [
              SizedBox(
                width: PlatformUtil.isMobile ? 300 : 250,
                child: widget.sidebar,
              ),
              const VerticalDivider(thickness: .7, width: 1),
              Expanded(
                flex: 1,
                child: widget.body,
              )
            ],
          );
        } else {
          // return mainView == TabletMainView.body ? body : sidebar;
          String title = S().appName;
          if (widget.body is CommonStatefulWidget) {
            title = (widget.body as CommonStatefulWidget).title();
            conversation = null;
          } else if (widget.body is BlocProvider<ChatBloc>) {
            title = conversation?.title ?? title;
          }

          return BlocProvider(
              create: (context) =>
                  ConversationsBloc(chatService: context.read<ChatService>())..add(const ConversationsRequested()),
              child:
                  //手机端增加appbar
                  Scaffold(
                appBar: CommonAppBar(title, currentConversation: conversation, hasAppBar: true),
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
