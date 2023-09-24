import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:chatty/api/http_request.dart';
import 'package:chatty/screens/screens.dart';
import 'package:chatty/util/navigation.dart';
import 'package:chatty/util/platform_util.dart';
import 'package:chatty/widgets/common_stateful_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../bloc/conversations_bloc.dart';
import '../bloc/conversations_event.dart';
import '../event/event_bus.dart';
import '../event/event_message.dart';
import '../generated/l10n.dart';
import '../models/conversation.dart';
import '../models/prompt.dart';
import '../screens/chat_screen.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import '../util/constants.dart';
import '../widgets/common_appbar.dart';
import '../widgets/conversation_edit_dialog.dart';

class EmptyChatScreenPage extends CommonStatefulWidget {
  const EmptyChatScreenPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EmptyChatScreen();
  }
}

class _EmptyChatScreen extends State<EmptyChatScreenPage> {
  late List<Prompt> promptList = [];

  void fetchPromptList() async {
    promptList = await HttpRequest.request<Prompt>(
        Urls.queryPromptByLanguageCode,
        params: {'language': LocalStorageService().currentLanguageCode},
        (p0) => Prompt.fromJson(p0));

    if (promptList.isNotEmpty) {
      LocalStorageService().promptListJson = jsonEncode(promptList);
      if (context.mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    fetchPromptList();
    super.initState();
  }

  Future<Conversation?> showConversationDialog(BuildContext context, bool isEdit, Conversation conversation) =>
      showDialog<Conversation?>(
          context: context,
          builder: (context) {
            return ConversationEditDialog(conversation: conversation, isEdit: isEdit);
          });

  Future<void> createConversation(ChatService chatService, ConversationsBloc bloc) async {
    var newConversation = await showConversationDialog(context, false, Conversation.create());
    if (newConversation != null) {
      await chatService.updateConversation(newConversation);
      var savedConversation = chatService.getConversationById(newConversation.id)!;
      if (context.mounted) {
        LocalStorageService().currentConversationId = newConversation.id;
        EventBus.getDefault().post(EventMessage<Conversation>(savedConversation));
      }
      bloc.add(const ConversationsRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var bloc = BlocProvider.of<ConversationsBloc>(context);

    return Scaffold(
      appBar: CommonAppBar(
        S.current.appName,
        hasAppBar: true,
        actionWidgets: PlatformUtil.isMobile
            ? [
                IconButton(
                    onPressed: () {
                      createConversation(chatService, bloc);
                    },
                    icon: const Icon(Icons.add_comment_rounded))
              ]
            : [],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 120, width: 120, child: Lottie.asset('assets/thinking.json', repeat: true)),
          PlatformUtil.isMobile ? const SizedBox.shrink() : const SizedBox(height: 20),
          Container(
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Column(
                children: [
                  Text(S.current.create_conversation_to_start,
                      style: const TextStyle(color: Colors.white70, fontSize: 18), textAlign: TextAlign.center),
                  Text(S.current.create_conversation_tip,
                      style: const TextStyle(color: Colors.white54, fontSize: 14), textAlign: TextAlign.center)
                ],
              )),
          Container(
              height: PlatformUtil.isMobile ? 400 : 275,
              width: PlatformDispatcher.instance.implicitView?.physicalSize.width,
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Stack(
                children: [
                  GridView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: ScrollController(),
                      itemCount: promptList.length,
                      // 允终邀动
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return promptItem(context, index,
                            Prompt(title: promptList[index].title, promptContent: promptList[index].promptContent), chatService);
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: PlatformUtil.isMobile ? 3 : 2,
                          mainAxisExtent: PlatformUtil.isMobile ? 185 : 200,
                          // 设置项宽度
                          crossAxisSpacing: 5,
                          // 水平间距
                          mainAxisSpacing: 5)),
                  if (promptList.isEmpty) const Center(child: CircularProgressIndicator(color: Colors.white30))
                ],
              )),
          if (PlatformUtil.isMobile) const SizedBox(height: 20)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CupertinoColors.secondaryLabel,
        foregroundColor: Colors.white70,
        shape: const CircleBorder(),
        onPressed: () {
          createConversation(chatService, bloc);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget promptItem(BuildContext context, int index, Prompt prompt, ChatService chatService) {
    MaterialColor randomColor = Colors.primaries[index % Colors.primaries.length];
    return GestureDetector(
      child: Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          decoration: BoxDecoration(color: randomColor.shade300, borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Text(prompt.title,
                  maxLines: 1,
                  style: TextStyle(
                      color: randomColor.shade900, fontSize: 15, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis)),
              const SizedBox(height: 5),
              Text(prompt.promptContent,
                  maxLines: 4, style: TextStyle(color: randomColor.shade800, fontSize: 13, overflow: TextOverflow.ellipsis))
            ],
          )),
      onTap: () async {
        Conversation newConversation = Conversation.create();
        newConversation.lastUpdated = DateTime.now();
        newConversation.title = prompt.title;
        newConversation.systemMessage = prompt.promptContent;
        LocalStorageService().currentConversationId = newConversation.id;

        await chatService.updateConversation(newConversation);
        var savedConversation = chatService.getConversationById(newConversation.id)!;

        if (context.mounted) {
          if (Platform.isAndroid || Platform.isIOS) {
            Navigation.navigatorChat(context, chatService, savedConversation);
          } else {
            Navigation.navigator(context, ChatScreenPage(currentConversation: savedConversation));
          }
        }
        var conversationsBloc = ConversationsBloc(chatService: chatService);
        conversationsBloc.add(const ConversationsRequested());
      },
    );
  }
}
