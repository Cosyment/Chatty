import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/conversations_bloc.dart';
import '../bloc/conversations_event.dart';
import '../models/conversation.dart';
import '../screens/chat_screen.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import '../util/android_back_desktop.dart';
import 'conversation_edit_dialog.dart';

class EmptyChatWidget extends StatelessWidget {
  const EmptyChatWidget({super.key});

  Future<Conversation?> showConversationDialog(
          BuildContext context, bool isEdit, Conversation conversation) =>
      showDialog<Conversation?>(
          context: context,
          builder: (context) {
            return ConversationEditDialog(
                conversation: conversation, isEdit: isEdit);
          });

  Future<bool> _onBackPressed() async {
    AndroidBackTop.backDeskTop(); //设置为返回不退出app
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var bloc = BlocProvider.of<ConversationsBloc>(context);

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          body: const SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat,
                    size: 100,
                  ),
                  Text('Create or choose a conversation to start'),
                  SizedBox(height: 150,)
                ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newConversation = await showConversationDialog(
              context, false, Conversation.create());
          if (newConversation != null) {
            await chatService.updateConversation(newConversation);
            var savedConversation =
                chatService.getConversationById(newConversation.id)!;
            if (context.mounted) {
              LocalStorageService().currentConversationId = newConversation.id;
              if (Navigator.of(context).canPop()) {
                Navigator.of(context)
                    .pushReplacement(ChatScreenPage.route(savedConversation));
                  } else {
                    Navigator.of(context)
                        .push(ChatScreenPage.route(savedConversation));
                  }
                }
                bloc.add(const ConversationsRequested());
              }
            },
            child: const Icon(Icons.add),
          ),
        ));
  }
}
