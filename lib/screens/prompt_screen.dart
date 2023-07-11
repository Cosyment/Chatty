import 'package:chatbotty/api/http_request.dart';
import 'package:chatbotty/bloc/conversations_bloc.dart';
import 'package:chatbotty/models/models.dart';
import 'package:chatbotty/screens/chat_screen.dart';
import 'package:chatbotty/services/chat_service.dart';
import 'package:chatbotty/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../bloc/conversations_event.dart';
import '../models/prompt.dart';
import '../services/local_storage_service.dart';
import '../util/platform_util.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PromptState();
  }
}

class _PromptState extends State<PromptScreen> {
  List<Prompt> promptList = [];

  @override
  void initState() {
    fetchPromptList();
    super.initState();
  }

  void fetchPromptList() async {
    var prompts = await HttpRequest.request<Prompt>(
        Urls.queryPromptByCountryCode,
        params: {'countryCode': LocalStorageService().currentCountryCode.toString()},
        (p0) => Prompt.fromJson(p0));

    if (prompts != null && prompts is List && prompts.isNotEmpty) {
      setState(() {
        for (var element in prompts) {
          promptList.add(Prompt(title: element.title, promptContent: element.promptContent));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ChatService chatService = context.read<ChatService>();

    return Scaffold(
        appBar: AppBar(title: Text('Prompt'), automaticallyImplyLeading: PlatformUtl.isMobile),
        body: MasonryGridView.count(
          crossAxisCount: 3,
          //几列
          mainAxisSpacing: 5,
          // 间距
          crossAxisSpacing: 5,
          // 纵向间距？
          itemCount: promptList.length,
          //元素个数
          itemBuilder: (context, index) {
            return promptItem(context, promptList[index], chatService);
          },
        ));
  }

  Widget promptItem(BuildContext context, Prompt prompt, ChatService chatService) {
    return GestureDetector(
      child: Container(
          margin: const EdgeInsets.fromLTRB(3, 3, 3, 3),
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Text(prompt.title, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(prompt.promptContent,
                  maxLines: 5, style: const TextStyle(color: Colors.white70, fontSize: 13, overflow: TextOverflow.ellipsis))
            ],
          )),
      onTap: () async {
        // ChatScreen
        Conversation newConversation = Conversation.create();
        newConversation.lastUpdated = DateTime.now();
        newConversation.title = prompt.title;
        newConversation.systemMessage = prompt.promptContent;

        await chatService.updateConversation(newConversation);
        var savedConversation = chatService.getConversationById(newConversation.id)!;
        if (context.mounted) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pushReplacement(ChatScreenPage.route(savedConversation));
          } else {
            Navigator.of(context).push(ChatScreenPage.route(savedConversation));
          }
        }

        var conversationsBloc = ConversationsBloc(chatService: chatService);
        conversationsBloc.add(const ConversationsRequested());
      },
    );
  }
}
