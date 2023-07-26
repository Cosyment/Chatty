import 'package:chatty/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../bloc/blocs.dart';
import '../models/models.dart';
import '../screens/screens.dart';
import '../services/chat_service.dart';
import '../widgets/widgets.dart';

class ConversationListWidget extends StatefulWidget {
  final Conversation? selectedConversation;

  const ConversationListWidget({super.key, this.selectedConversation});

  @override
  State<ConversationListWidget> createState() => _ConversationListWidgetState();
}

class _ConversationListWidgetState extends State<ConversationListWidget> {
  Conversation? selectedConversation;
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    selectedConversation = widget.selectedConversation;
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<Conversation?> showConversationDialog(
          BuildContext context, bool isEdit, Conversation conversation) =>
      showDialog<Conversation?>(
          context: context,
          builder: (context) {
            return ConversationEditDialog(
                conversation: conversation, isEdit: isEdit);
          });

  Future<bool?> showDeleteConfirmDialog(BuildContext context) =>
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            title: AppLocalizations.of(context)!.delete_conversation,
            content: AppLocalizations.of(context)!.delete_conversation_tips,
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var bloc = BlocProvider.of<ConversationsBloc>(context);
    final state = context.watch<ConversationsBloc>().state;
    var conversations = state.conversations;

    if (selectedConversation == null &&
        LocalStorageService().currentConversationId != null) {
      selectedConversation = chatService
          .getConversationById(LocalStorageService().currentConversationId);
    }

    return Flexible(
        child: ListView.builder(
      controller: _scrollController,
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        var conversationIndex = conversations[index];
        return ListTile(
          title: Text(conversationIndex.title,
              style: const TextStyle(overflow: TextOverflow.ellipsis)),
          horizontalTitleGap: 5,
          contentPadding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
          selected: conversations[index].id == selectedConversation?.id,
          selectedTileColor: Color.lerp(
              Theme.of(context).colorScheme.background, Colors.white, 0.05),
          onTap: () async {
            var id = conversations[index].id;
            var conversation = chatService.getConversationById(id);
            if (conversation != null) {
              if (context.mounted) {
                setState(() {
                  LocalStorageService().currentConversationId = id;
                });
                ChatScreenPage.navigator(context, conversation);
              }
            }
          },
          trailing: conversations[index].id == selectedConversation?.id
              ? null
              : PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(AppLocalizations.of(context)!.edit),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(AppLocalizations.of(context)!.delete),
                      ),
                    ];
                  },
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        var id = conversations[index].id;
                        var conversation = chatService.getConversationById(id);
                        if (conversation == null) {
                          break;
                        }
                        var newConversation = await showConversationDialog(
                            context, true, conversation);
                        if (newConversation != null) {
                          await chatService.updateConversation(newConversation);
                          setState(() {
                            bloc.add(const ConversationsRequested());
                          });
                        }
                        break;
                      case 'delete':
                        var result = await showDeleteConfirmDialog(context);
                        if (result == true) {
                          if (context.mounted &&
                              (conversations[index].id ==
                                  selectedConversation?.id)) {
                            Navigator.popUntil(context,
                                (Route<dynamic> route) => route.isFirst);
                          }
                          bloc.add(ConversationDeleted(conversations[index]));
                        }
                        break;
                      default:
                        break;
                    }
                  },
                ),
        );
      },
    ));
  }
}
