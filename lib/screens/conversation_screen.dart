import 'package:chatty/util/navigation.dart';
import 'package:chatty/util/platform_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../bloc/conversations_bloc.dart';
import '../bloc/conversations_event.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
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
    if (currentConversation != widget.selectedConversation) {
      setState(() {
        currentConversation = widget.selectedConversation;
      });
    }

    print('---------------ConversationScreen>>>${currentConversation?.title}');

    return Scaffold(
      appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.conversations),
              currentConversation != null
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
                        }
                        setState(() {
                          currentConversation = null;
                          Future.delayed(Duration.zero, () {
                            Navigation.navigator(
                                context, const EmptyChatScreen());
                          });
                        });
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
                ? ConversationListWidget(
                    selectedConversation: currentConversation)
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
                                ChatScreenPage.navigator(
                                    context, savedConversation);
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
