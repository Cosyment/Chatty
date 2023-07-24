import 'package:chatty/screens/tablet_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_bloc.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import 'chat_screen.dart';
import 'conversation_screen.dart';
import 'empty_chat_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var conversation = chatService
        .getConversationById(LocalStorageService().currentConversationId);

    return TabletScreenPage(
      sidebar: ConversationScreen(selectedConversation: conversation),
      body: conversation == null
          ? const EmptyChatScreen()
          : BlocProvider(
          create: (context) => ChatBloc(
              chatService: chatService, initialConversation: conversation),
          child: const ChatScreen()),
      mainView: TabletMainView.sidebar,
    );
  }
}