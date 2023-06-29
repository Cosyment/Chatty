import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatbotty/services/local_storage_service.dart';
import 'package:chatbotty/widgets/empty_chat_widget.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/conversations_bloc.dart';
import '../bloc/conversations_event.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/conversation_edit_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TabletScreenPage extends StatelessWidget {
  final Widget sidebar;
  final Widget body;
  final TabletMainView mainView;

  const TabletScreenPage(
      {super.key,
      required this.sidebar,
      required this.body,
      this.mainView = TabletMainView.body});

  Future<Conversation?> showConversationDialog(
          BuildContext context, bool isEdit, Conversation conversation) =>
      showDialog<Conversation?>(
          context: context,
          builder: (context) {
            return ConversationEditDialog(
                conversation: conversation, isEdit: isEdit);
          });

  Future<bool?> showClearConfirmDialog(BuildContext context) =>
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            title: AppLocalizations.of(context)!.clear_conversation,
            content: AppLocalizations.of(context)!.clear_conversation_tips,
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var conversation = chatService
        .getConversationById(LocalStorageService().currentConversationId);
    var title = (conversation?.title == null || body is EmptyChatWidget)
        ? AppLocalizations.of(context)!.appName
        : conversation?.title;

    ChatBloc? chatBloc;
    ConversationsBloc? conversationsBloc;
    if (conversation != null) {
      // chatBloc = BlocProvider.of<ChatBloc>(context);
      // conversationsBloc = BlocProvider.of<ConversationsBloc>(context);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var size = MediaQuery.of(context).size;
        if (size.width > size.height) {
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

          //手机端增加appbar
          return Scaffold(
            appBar: AppBar(
                title: Text(title!,
                    style: const TextStyle(overflow: TextOverflow.ellipsis)),
                // automaticallyImplyLeading: false,
                actions: <Widget>[
                  // IconButton(
                  //   icon: const Icon(Icons.info),
                  //   onPressed: () {
                  //     // setState(() {
                  //     //   _showSystemMessage = !_showSystemMessage;
                  //     // });
                  //   },
                  // ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(AppLocalizations.of(context)!.edit),
                        ),
                        PopupMenuItem(
                          value: 'clear',
                          child: Text(AppLocalizations.of(context)!
                              .clear_conversation),
                        ),
                      ];
                    },
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          var newConversation = await showConversationDialog(
                              context, true, conversation!);
                          if (newConversation != null) {
                            conversation.lastUpdated = DateTime.now();
                            title = newConversation.title;
                            await chatService
                                .updateConversation(newConversation);
                            chatBloc?.add(ChatLastUpdatedChanged(
                                conversation, conversation.lastUpdated));
                            conversationsBloc
                                ?.add(const ConversationsRequested());
                          }
                          break;
                        case 'clear':
                          var result = await showClearConfirmDialog(context);
                          if (result == true) {
                            conversation?.messages = [];
                            conversation?.lastUpdated = DateTime.now();
                            await chatService.updateConversation(conversation!);
                            chatBloc?.add(ChatLastUpdatedChanged(
                                conversation, conversation.lastUpdated));
                            conversationsBloc
                                ?.add(const ConversationsRequested());
                          }
                          break;
                        default:
                          break;
                      }
                    },
                  ),
                ]),
            drawer: Drawer(
              //New added
              width: 250.toDouble(),
              child: sidebar, //New added
            ), //New added
            body: Center(
              child: body,
            ),
          );
        }
      },
    );
  }
}

enum TabletMainView { sidebar, body }
