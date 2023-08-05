import 'package:chatty/event/event_bus.dart';
import 'package:chatty/event/event_message.dart';
import 'package:chatty/util/navigation.dart';
import 'package:chatty/util/platform_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../bloc/conversations_bloc.dart';
import '../bloc/conversations_event.dart';
import '../generated/l10n.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/theme_color.dart';
import '../widgets/widgets.dart';
import 'screens.dart';

class ConversationScreen extends StatefulWidget {
  final Conversation? selectedConversation;

  const ConversationScreen({super.key, this.selectedConversation});

  @override
  State<StatefulWidget> createState() {
    return _ConversationScreen();
  }
}

class _ConversationScreen extends State<ConversationScreen> {
  late Conversation? currentConversation = widget.selectedConversation;

  Future<Conversation?> showConversationDialog(BuildContext context, bool isEdit, Conversation conversation) =>
      showDialog<Conversation?>(
          context: context,
          builder: (context) {
            return ConversationEditDialog(conversation: conversation, isEdit: isEdit);
          });

  Future<bool?> showCleanConfirmDialog(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            title: S.current.reminder,
            content: S.current.clean_conversation_tips,
          );
        },
      );

  @override
  void initState() {
    EventBus.getDefault().register<EventMessage<Conversation>>(this, (event) {
      setState(() {
        currentConversation = event.data;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var conversationsBloc = BlocProvider.of<ConversationsBloc>(context);
    if (currentConversation != widget.selectedConversation) {
      setState(() {
        currentConversation = widget.selectedConversation;
      });
    }

    return Scaffold(
      appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.current.conversations),
              currentConversation != null
                  ? IconButton(
                      onPressed: () async {
                        var result = await showCleanConfirmDialog(context);
                        if (result == true) {
                          List<ConversationIndex> list = chatService.getConversationList();
                          for (var element in list) {
                            chatService.removeConversationById(element.id);
                            LocalStorageService().removeConversationJsonById(element.id);
                          }

                          setState(() {
                            list.clear();
                            currentConversation = null;
                            Future.delayed(Duration.zero, () {
                              Navigation.navigator(context, const EmptyChatScreen());
                            });
                          });
                        }
                      },
                      icon: const Icon(Icons.cleaning_services_outlined))
                  : const SizedBox()
            ],
          ),
          automaticallyImplyLeading: false),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            currentConversation != null
                ? ConversationListWidget(selectedConversation: currentConversation)
                : Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child:
                        Center(child: SizedBox(width: 100, height: 100, child: Lottie.asset('assets/empty.json', repeat: true)))),
            const Divider(thickness: .5),
            Container(
                color: ThemeColor.backgroundColor,
                width: PlatformUtil.isMobile ? 300 : 250,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      textButton(S.current.new_conversation, Icons.add_box_outlined, () async {
                        var newConversation = await showConversationDialog(context, false, Conversation.create());
                        if (newConversation != null) {
                          LocalStorageService().currentConversationId = newConversation.id;

                          await chatService.updateConversation(newConversation);
                          var savedConversation = chatService.getConversationById(newConversation.id)!;
                          conversationsBloc.add(const ConversationsRequested());
                          if (context.mounted) {
                            closeDrawer();
                            Navigation.navigator(context, ChatScreenPage(currentConversation: newConversation));
                          }
                        }
                      }),
                      const SizedBox(
                        height: 6,
                      ),
                      textButton(S.current.prompt, Icons.tips_and_updates_outlined, () {
                        closeDrawer();
                        Navigation.navigator(context, const PromptScreen());
                      }),
                      const SizedBox(
                        height: 6,
                      ),
                      textButton(S.current.settings, Icons.settings_outlined, () {
                        closeDrawer();
                        Navigation.navigator(context, const SettingsScreenPage());
                      }),
                      const SizedBox(
                        height: 6,
                      ),
                      FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (context, packageInfo) {
                            return textButton("${S.current.version}: v${packageInfo.data?.version}", Icons.info_outline, () {});
                          })
                    ]))),
          ],
        ),
      ),
    );
  }

  void closeDrawer() {
    if (PlatformUtil.isMobile) {
      EventBus.getDefault().post(EventMessage<EventType>(EventType.CLOSE_DRAWER));
    }
  }

  @override
  void dispose() {
    EventBus.getDefault().unregister(this);
    super.dispose();
  }

  Widget textButton(String value, IconData iconData, VoidCallback? onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      label: Text(value, style: const TextStyle(color: Colors.white70)),
      icon: Icon(iconData, color: Colors.white70, size: 20.0),
    );
  }
}
