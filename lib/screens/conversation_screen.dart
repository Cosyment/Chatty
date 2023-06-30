import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../bloc/blocs.dart';
import '../models/models.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/widgets.dart';
import 'screens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    var bloc = BlocProvider.of<ConversationsBloc>(context);

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
                              bloc.add(const ConversationsRequested());
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
                          closeDrawer();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const SettingsScreenPage()));
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
                              onPressed: () {},
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
