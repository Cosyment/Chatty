import 'package:chatbotty/util/platform_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/conversations_bloc.dart';
import '../bloc/conversations_event.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/widgets.dart';
import 'screens.dart';

class ConversationScreenPage extends StatelessWidget {
  const ConversationScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var conversation = chatService
        .getConversationById(LocalStorageService().currentConversationId);

    return TabletScreenPage(
      sidebar: const ConversationScreen(),
      body: conversation == null
          ? const EmptyChatWidget()
          : BlocProvider(
              create: (context) => ChatBloc(
                  chatService: chatService, initialConversation: conversation),
              child: const ChatScreen()),
      mainView: TabletMainView.sidebar,
    );
  }
}

class ConversationScreen extends StatelessWidget {
  final Conversation? selectedConversation;

  const ConversationScreen({super.key, this.selectedConversation});

  Future<Conversation?> showConversationDialog(
          BuildContext context, bool isEdit, Conversation conversation) =>
      showDialog<Conversation?>(
          context: context,
          builder: (context) {
            return ConversationEditDialog(
                conversation: conversation, isEdit: isEdit);
          });

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var conversationsBloc = BlocProvider.of<ConversationsBloc>(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.conversations),
          automaticallyImplyLeading: false),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConversationListWidget(selectedConversation: selectedConversation),
            const Divider(thickness: .5),
            Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                          onPressed: () async {
                            closeDrawer();
                            var newConversation = await showConversationDialog(
                                context, false, Conversation.create());
                            if (newConversation != null) {
                              LocalStorageService().currentConversationId =
                                  newConversation.id;

                              await chatService
                                  .updateConversation(newConversation);
                              var savedConversation = chatService
                                  .getConversationById(newConversation.id)!;
                              if (context.mounted) {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pushReplacement(
                                      ChatScreenPage.route(savedConversation));
                                } else {
                                  Navigator.of(context).push(
                                      ChatScreenPage.route(savedConversation));
                                }
                              }
                              conversationsBloc
                                  .add(const ConversationsRequested());
                            }
                          },
                          label: Text(
                              AppLocalizations.of(context)!.new_conversation),
                          icon: const Icon(Icons.add_box)),

                      const SizedBox(
                        height: 6,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          if (PlatformUtl.isMobile) {
                            closeDrawer();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>  PromptScreen()));
                          } else {
                            //pc,macos,web
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context)
                                  .pushReplacement(SettingsScreenPage.route());
                            } else {
                              Navigator.of(context)
                                  .push(SettingsScreenPage.route());
                            }
                          }
                        },
                        label: Text('Prompt'),
                        icon: const Icon(Icons.add_road_sharp),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      TextButton.icon(
                        onPressed: () {
                          if (PlatformUtl.isMobile) {
                            closeDrawer();
                             Navigator.of(context).push(MaterialPageRoute(
                                 builder: (_) => const SettingsScreenPage()));
                          } else {
                            //pc,macos,web
                             if (Navigator.of(context).canPop()) {
                               Navigator.of(context)
                                   .pushReplacement(SettingsScreenPage.route());
                             } else {
                               Navigator.of(context)
                                   .push(SettingsScreenPage.route());
                             }
                          }
                        },
                        label: Text(AppLocalizations.of(context)!.settings),
                        icon: const Icon(Icons.settings),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (context, packageInfo) {
                            return TextButton.icon(
                              onPressed: () async {},
                              label: Text(
                                  "${AppLocalizations.of(context)!.version}: v${packageInfo.data?.version}"),
                              icon: const Icon(Icons.info),
                            );
                          })
                    ])),
          ],
        ),
      ),
    );
  }

  void closeDrawer() {
    // if (GetPlatform.isMobile) {
    //   Get.back();
    // }
  }
}
