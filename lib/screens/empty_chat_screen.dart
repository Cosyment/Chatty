import 'dart:convert';
import 'dart:ui';

import 'package:chatty/api/http_request.dart';
import 'package:chatty/util/platform_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';

import '../bloc/conversations_bloc.dart';
import '../bloc/conversations_event.dart';
import '../models/conversation.dart';
import '../models/prompt.dart';
import '../screens/chat_screen.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import '../util/android_back_desktop.dart';
import '../util/constants.dart';
import '../widgets/conversation_edit_dialog.dart';

class EmptyChatScreen extends StatefulWidget {
  const EmptyChatScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EmptyChatScreen();
  }
}

class _EmptyChatScreen extends State<EmptyChatScreen> {
  late List<Prompt> promptList = [];

  void fetchPromptList() async {
    promptList = await HttpRequest.request<Prompt>(
        Urls.queryPromptByLanguageCode,
        params: {'language': PlatformDispatcher.instance.locale.languageCode},
        (p0) => Prompt.fromJson(p0));

    if (promptList.isNotEmpty) {
      LocalStorageService().promptListJson = jsonEncode(promptList);
      setState(() {});
    }
  }

  @override
  void initState() {
    fetchPromptList();
    super.initState();
  }

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
        child: SafeArea(
          child: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 150,
                    width: 150,
                    child: Lottie.asset('assets/thinking.json', repeat: true)),
                PlatformUtil.isMobile
                    ? const SizedBox.shrink()
                    : const SizedBox(height: 20),
                Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      children: [
                        Text(
                            AppLocalizations.of(context)!
                                .create_conversation_to_start,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 18),
                            textAlign: TextAlign.center),
                        Text(
                            AppLocalizations.of(context)!
                                .create_conversation_tip,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 14),
                            textAlign: TextAlign.center)
                      ],
                    )),
                Container(
                    height: PlatformUtil.isMobile ? 445 : 275,
                    width: PlatformDispatcher
                        .instance.implicitView?.physicalSize.width,
                    margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: promptList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return promptItem(
                              context,
                              Prompt(
                                  title: promptList[index].title,
                                  promptContent:
                                      promptList[index].promptContent),
                              chatService);
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: PlatformUtil.isMobile ? 3 : 2,
                            mainAxisExtent: PlatformUtil.isMobile ? 185 : 200,
                            // 设置项宽度
                            crossAxisSpacing: 5,
                            // 水平间距
                            mainAxisSpacing: 5)))
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: CupertinoColors.secondaryLabel,
              foregroundColor: Colors.white70,
              shape: const CircleBorder(),
              onPressed: () async {
                var newConversation = await showConversationDialog(
                    context, false, Conversation.create());
                if (newConversation != null) {
                  await chatService.updateConversation(newConversation);
                  var savedConversation =
                      chatService.getConversationById(newConversation.id)!;
                  if (context.mounted) {
                    LocalStorageService().currentConversationId =
                        newConversation.id;
                    ChatScreenPage.navigator(context, savedConversation);
                  }
                  bloc.add(const ConversationsRequested());
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
        ));
  }

  Widget promptItem(
      BuildContext context, Prompt prompt, ChatService chatService) {
    return GestureDetector(
      child: Container(
          margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
              color: Colors.white10, borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Text(prompt.title,
                  maxLines: 1,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis)),
              const SizedBox(height: 5),
              Text(prompt.promptContent,
                  maxLines: 4,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis))
            ],
          )),
      onTap: () async {
        Conversation newConversation = Conversation.create();
        newConversation.lastUpdated = DateTime.now();
        newConversation.title = prompt.title;
        newConversation.systemMessage = prompt.promptContent;
        LocalStorageService().currentConversationId = newConversation.id;

        await chatService.updateConversation(newConversation);
        var savedConversation =
            chatService.getConversationById(newConversation.id)!;
        if (context.mounted) {
          ChatScreenPage.navigator(context, savedConversation);
        }
        var conversationsBloc = ConversationsBloc(chatService: chatService);
        conversationsBloc.add(const ConversationsRequested());

        // EventBus.getDefault().post(EventMessage(newConversation));
      },
    );
  }
}