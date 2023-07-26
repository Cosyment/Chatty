import 'package:chatty/event/event_bus.dart';
import 'package:chatty/event/event_message.dart';
import 'package:chatty/screens/tablet_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
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
    EventBus.getDefault().register<EventMessage<Widget>>(this, (event) {
      setState(() {
        body = event.data;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    Conversation? conversation = chatService
        .getConversationById(LocalStorageService().currentConversationId);
    if (body is ChatScreenPage) {
      setState(() {
        body = BlocProvider(
            create: (context) => ChatBloc(
                chatService: chatService, initialConversation: conversation!),
            child: const ChatScreen());
      });
    }
    debugPrint('---------------->>>build conversation ${conversation?.title}');

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
