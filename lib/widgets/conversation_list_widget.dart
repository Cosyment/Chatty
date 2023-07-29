import 'package:chatty/event/event_bus.dart';
import 'package:chatty/event/event_message.dart';
import 'package:chatty/services/local_storage_service.dart';
import 'package:chatty/util/platform_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blocs.dart';
import '../generated/l10n.dart';
import '../models/models.dart';
import '../screens/screens.dart';
import '../services/chat_service.dart';
import '../util/navigation.dart';
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

  Future<Conversation?> showConversationDialog(BuildContext context, bool isEdit, Conversation conversation) =>
      showDialog<Conversation?>(
          context: context,
          builder: (context) {
            return ConversationEditDialog(conversation: conversation, isEdit: isEdit);
          });

  Future<bool?> showDeleteConfirmDialog(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            title: S.current.delete_conversation,
            content: S.current.delete_conversation_tips,
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var bloc = BlocProvider.of<ConversationsBloc>(context);
    final state = context.watch<ConversationsBloc>().state;
    // var conversations = state.conversations;
    var conversations = chatService.getConversationList();

    if (LocalStorageService().currentConversationId != null) {
      selectedConversation = chatService.getConversationById(LocalStorageService().currentConversationId);
    }

    return Flexible(
        child: ListView.builder(
      controller: _scrollController,
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        var conversationIndex = conversations[index];
        return ListTile(
          title: Text(conversationIndex.title, style: const TextStyle(overflow: TextOverflow.ellipsis)),
          horizontalTitleGap: 5,
          contentPadding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
          selected: conversations[index].id == selectedConversation?.id,
          selectedTileColor: Color.lerp(Theme.of(context).colorScheme.background, Colors.white, 0.05),
          onTap: () async {
            var id = conversations[index].id;
            var conversation = chatService.getConversationById(id);
            if (conversation != null) {
              selectedConversation = conversation;
              if (context.mounted) {
                setState(() {
                  if (PlatformUtil.isMobile) {
                    EventBus.getDefault().post(EventMessage<EventType>(EventType.CLOSE_DRAWER));
                  }
                  LocalStorageService().currentConversationId = id;
                  Navigation.navigator(context, ChatScreenPage(currentConversation: selectedConversation));
                });
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
                        child: Text(S.current.edit),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(S.current.delete),
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
                        var newConversation = await showConversationDialog(context, true, conversation);
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
                          if (context.mounted && (conversations[index].id == selectedConversation?.id)) {
                            Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
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
