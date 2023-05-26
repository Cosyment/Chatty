import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/screens/setting_screen.dart';

import '../bloc/chat_bloc.dart';

class TabletScreenPage extends StatelessWidget {
  final Widget sidebar;
  final Widget body;
  final TabletMainView mainView;

  const TabletScreenPage(
      {super.key,
      required this.sidebar,
      required this.body,
      this.mainView = TabletMainView.body});

  @override
  Widget build(BuildContext context) {
    // final state = context.watch<ChatBloc>().state;
    // var conversation = state.initialConversation;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (kIsWeb ||
            Platform.isWindows ||
            Platform.isMacOS ||
            Platform.isLinux) {
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
          return Scaffold(
            appBar: AppBar(
                title: const Text("聊天",
                    style: TextStyle(overflow: TextOverflow.ellipsis)),
                // automaticallyImplyLeading: false,
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () {
                      // setState(() {
                      //   _showSystemMessage = !_showSystemMessage;
                      // });
                    },
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'clear',
                          child: Text('Clear conversation'),
                        ),
                      ];
                    },
                    onSelected: (value) async {
                      // switch (value) {
                        // case 'edit':
                        //   var newConversation = await showConversationDialog(context, true, conversation);
                        //   if (newConversation != null) {
                        //     conversation.lastUpdated = DateTime.now();
                        //     await chatService.updateConversation(newConversation);
                        //     chatBloc.add(ChatLastUpdatedChanged(conversation, conversation.lastUpdated));
                        //     conversationsBloc.add(const ConversationsRequested());
                        //   }
                        //   break;
                        // case 'clear':
                        //   var result = await showClearConfirmDialog(context);
                        //   if (result == true) {
                        //     conversation.messages = [];
                        //     conversation.lastUpdated = DateTime.now();
                        //     await chatService.updateConversation(conversation);
                        //     chatBloc.add(ChatLastUpdatedChanged(conversation, conversation.lastUpdated));
                        //     conversationsBloc.add(const ConversationsRequested());
                        //   }
                        //   break;
                        // default:
                        //   break;
                      // }
                    },
                  ),
                ]),
            drawer: Drawer(
              //New added
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
