import 'package:chatbotty/bloc/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../util/platform_util.dart';
import 'confirm_dialog.dart';
import 'conversation_edit_dialog.dart';

class ChatScreenAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Conversation? currentConversation;

  const ChatScreenAppBar({
    super.key,
    this.currentConversation,
  });

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
  State<StatefulWidget> createState() {
    return _ChatScreenAppbar();
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class _ChatScreenAppbar extends State<ChatScreenAppBar> {
  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var conversationsBloc = BlocProvider.of<ConversationsBloc>(context);

    return AppBar(
        title: Text(widget.currentConversation?.title ?? 'Chatbotty',
            style: const TextStyle(overflow: TextOverflow.ellipsis)),
        automaticallyImplyLeading:PlatformUtl.isMobile,
        actions: widget.currentConversation == null
            ? []
            : <Widget>[
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
                        child: Text(
                            AppLocalizations.of(context)!.clear_conversation),
                      ),
                    ];
                  },
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        var newConversation =
                            await widget.showConversationDialog(
                                context, true, widget.currentConversation!);
                        if (newConversation != null) {
                          widget.currentConversation?.lastUpdated =
                              DateTime.now();
                          setState(() {
                            widget.currentConversation?.title =
                                newConversation.title;
                          });

                          await chatService.updateConversation(newConversation);

                          var chatBloc = ChatBloc(
                              chatService: chatService,
                              initialConversation: newConversation);

                          chatBloc.add(ChatLastUpdatedChanged(
                              newConversation, newConversation.lastUpdated));
                          conversationsBloc.add(const ConversationsRequested());
                        }
                        break;
                      case 'clear':
                        var result =
                            await widget.showClearConfirmDialog(context);
                        if (result == true) {
                          widget.currentConversation?.messages = [];
                          widget.currentConversation?.lastUpdated =
                              DateTime.now();

                          await chatService.updateConversation(widget.currentConversation!);

                          var chatBloc = ChatBloc(
                              chatService: chatService,
                              initialConversation: widget.currentConversation!);

                          chatBloc.add(ChatLastUpdatedChanged(
                              widget.currentConversation!, widget.currentConversation!.lastUpdated));
                          conversationsBloc.add(const ConversationsCleared());
                        }
                        break;
                      default:
                        break;
                    }
                  },
                ),
              ]);
  }
}
