import 'package:chatty/event/event_bus.dart';
import 'package:chatty/event/event_message.dart';
import 'package:chatty/screens/tablet_screen.dart';
import 'package:chatty/widgets/common_stateful_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import '../util/ads_manager.dart';
import 'chat_screen.dart';
import 'conversation_screen.dart';
import 'empty_chat_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainScreen();
  }
}

class _MainScreen extends State<MainScreen> {
  late Widget body = const EmptyChatScreen();

  @override
  void initState() {
    AdsManager.loadAd();
    EventBus.getDefault().register<EventMessage<CommonStatefulWidget>>(this, (event) {
      setState(() {
        body = event.data;
      });
    });

    if (LocalStorageService().currentConversationId != null) {
      body = ChatScreenPage();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    Conversation? conversation = chatService.getConversationById(LocalStorageService().currentConversationId);

    if (body is ChatScreenPage) {
      setState(() {
        if (conversation != null) {
          body = BlocProvider(
              create: (context) => ChatBloc(chatService: chatService, initialConversation: conversation), child: body);
        } else {
          body = const EmptyChatScreen();
        }
      });
    }

    return TabletScreenPage(
      sidebar: ConversationScreen(selectedConversation: conversation),
      body: body,
      mainView: TabletMainView.sidebar,
    );
  }

  @override
  void dispose() {
    EventBus.getDefault().unregister(this);
    super.dispose();
  }
}
