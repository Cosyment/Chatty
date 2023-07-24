import 'dart:ui';

import 'package:chatty/util/navigation.dart';
import 'package:chatty/util/platform_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
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
          ? const EmptyChatScreen()
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

  Future<bool?> showCleanConfirmDialog(BuildContext context) =>
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            title: AppLocalizations.of(context)!.clean_conversation,
            content: AppLocalizations.of(context)!.clean_conversation_tips,
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var conversationsBloc = BlocProvider.of<ConversationsBloc>(context);

    return Scaffold(
      appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.conversations),
              selectedConversation != null
                  ? IconButton(
                      onPressed: () async {
                        var result = await showCleanConfirmDialog(context);
                        if (result == true) {
                          List<ConversationIndex> list =
                              chatService.getConversationList();
                          for (var element in list) {
                            chatService.removeConversationById(element.id);
                            LocalStorageService()
                                .removeConversationJsonById(element.id);
                          }
                          Navigation.navigator(
                              context, const EmptyChatScreen());
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
            selectedConversation != null
                ? ConversationListWidget(
                    selectedConversation: selectedConversation)
                : Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Center(
                        child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Lottie.asset('assets/empty.json',
                                repeat: true)))),
            const Divider(thickness: .5),
            Container(
                color: CupertinoColors.darkBackgroundGray,
                width: 300,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textButton(
                              AppLocalizations.of(context)!.new_conversation,
                              Icons.add_box_outlined, () async {
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
                          }),
                          const SizedBox(
                            height: 6,
                          ),
                          textButton(AppLocalizations.of(context)!.prompt,
                              Icons.tips_and_updates_outlined, () {
                            Navigation.navigator(context, const PromptScreen());
                          }),
                          const SizedBox(
                            height: 6,
                          ),
                          textButton(AppLocalizations.of(context)!.settings,
                              Icons.settings_outlined, () {
                            if (PlatformUtil.isMobile) {
                              closeDrawer();
                            }
                            Navigation.navigator(
                                context, const SettingsScreenPage());
                          }),
                          const SizedBox(
                            height: 6,
                          ),
                          FutureBuilder<PackageInfo>(
                              future: PackageInfo.fromPlatform(),
                              builder: (context, packageInfo) {
                                return textButton(
                                    "${AppLocalizations.of(context)!.version}: v${packageInfo.data?.version}",
                                    Icons.info_outline,
                                    () {});
                              })
                        ]))),
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

  Widget textButton(String value, IconData iconData, VoidCallback? onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      label: Text(value, style: const TextStyle(color: Colors.white70)),
      icon: Icon(iconData, color: Colors.white70, size: 20.0),
    );
  }
}
