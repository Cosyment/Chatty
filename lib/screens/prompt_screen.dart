import 'dart:convert';
import 'dart:io';

import 'package:chatty/api/http_request.dart';
import 'package:chatty/bloc/conversations_bloc.dart';
import 'package:chatty/models/models.dart';
import 'package:chatty/screens/chat_screen.dart';
import 'package:chatty/services/chat_service.dart';
import 'package:chatty/util/constants.dart';
import 'package:chatty/util/navigation.dart';
import 'package:chatty/widgets/common_stateful_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../bloc/conversations_event.dart';
import '../generated/l10n.dart';
import '../models/prompt.dart';
import '../services/local_storage_service.dart';
import '../widgets/common_appbar.dart';

class PromptScreenPage extends CommonStatefulWidget {
  const PromptScreenPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PromptState();
  }

  @override
  String title() => S.current.prompt;
}

class _PromptState extends State<PromptScreenPage> {
  late List<Prompt> promptList = [];

  @override
  void initState() {
    if (promptList.isEmpty) {
      fetchPromptList();
    }
    super.initState();
  }

  void fetchPromptList() async {
    promptList = await HttpRequest.request<Prompt>(
        Urls.queryPromptByLanguageCode,
        // params: {'language': PlatformDispatcher.instance.locale.languageCode},
        params: {'language': LocalStorageService().currentLanguageCode},
        (p0) => Prompt.fromJson(p0));

    if (context.mounted && promptList.isNotEmpty) {
      LocalStorageService().promptListJson = jsonEncode(promptList);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    ChatService chatService = context.read<ChatService>();
    return Scaffold(
        appBar: CommonAppBar(S.current.prompt),
        body: Stack(
          children: [
            MasonryGridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              padding: const EdgeInsets.all(10),
              itemCount: promptList.length,
              itemBuilder: (context, index) {
                return promptItem(context, index, promptList[index], chatService);
              },
            ),
            if (promptList.isEmpty) const Center(child: CircularProgressIndicator(color: Colors.white30))
          ],
        ));
  }

  Widget promptItem(BuildContext context, int index, Prompt prompt, ChatService chatService) {
    MaterialColor randomColor = Colors.primaries[index % Colors.primaries.length];
    return InkWell(
      hoverColor: Colors.black45,
      radius: 10,
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: Container(
          margin: const EdgeInsets.fromLTRB(3, 3, 3, 3),
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          decoration: BoxDecoration(color: randomColor.shade300, borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Text(prompt.title, style: TextStyle(color: randomColor.shade900, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(prompt.promptContent,
                  maxLines: 5, style: TextStyle(color: randomColor.shade800, fontSize: 13, overflow: TextOverflow.ellipsis))
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
        var conversationsBloc = ConversationsBloc(chatService: chatService);
        conversationsBloc.add(const ConversationsRequested());

        if (context.mounted) {
          if (Platform.isAndroid || Platform.isIOS) {
            Navigation.navigatorChat(context, chatService, savedConversation);
          } else {
            Navigation.navigator(context, ChatScreenPage(currentConversation: savedConversation));
          }
        }
      },
    );
  }
}
