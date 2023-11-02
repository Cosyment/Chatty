import 'dart:io';
import 'dart:ui';

import 'package:chatty/models/conversation.dart';
import 'package:chatty/screens/screens.dart';
import 'package:chatty/widgets/common_stateful_widget.dart';
import 'package:chatty/widgets/theme_color.dart';
import 'package:chatty/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';

import '../bloc/conversations_bloc.dart';
import '../bloc/conversations_event.dart';
import '../generated/l10n.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import '../util/navigation.dart';
import 'chat_screen.dart';

class HomeScreenPage extends CommonStatefulWidget {
  const HomeScreenPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenPage> {
  final ShakeAnimationController _shakeAnimationController = ShakeAnimationController();

  void startShake() async {
    Future.delayed(const Duration(seconds: 1), () async {
      _shakeAnimationController.start(shakeCount: 1);
      await Future.delayed(const Duration(milliseconds: 2500));
      startShake();
    });
  }

  Future<Conversation?> showConversationDialog(BuildContext context, bool isEdit, Conversation conversation) =>
      showDialog<Conversation?>(
          context: context,
          builder: (context) {
            return ConversationEditDialog(conversation: conversation, isEdit: isEdit);
          });

  Future<bool?> showDeleteConfirmDialog(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            title: S.current.delete_conversation,
            content: S.current.delete_conversation_tips,
          );
        },
      );

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
    startShake();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    List<ConversationIndex> conversationIndexs = chatService.getConversationList();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.passthrough,
          alignment: AlignmentDirectional.topCenter,
          children: [
            Positioned.fill(child: Image.asset('assets/images/home.jpeg', fit: BoxFit.cover)),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 0,
                  sigmaY: 0,
                ),
                child: Container(
                  color: Colors.black.withOpacity(.1),
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: LocalStorageService().isPad ? 100 : 50, width: MediaQuery.of(context).size.width),
                // SizedBox(height: 250, width: 250, child: Lottie.asset('assets/animation_lnnacc87.json', repeat: true)),
                const SizedBox(
                  height: 230,
                ),
                Container(
                  // width: MediaQuery.of(context).size.width,
                  width: 400,
                  height: 300,
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      color: ThemeColor.appBarBackgroundColor.withOpacity(0.5),
                      borderRadius: const BorderRadiusDirectional.all(Radius.circular(10))),
                  child: conversationIndexs.isEmpty
                      // conversationIndexs.length < 10
                      ? Center(child: SizedBox(height: 150, width: 150, child: Lottie.asset('assets/empty.json', repeat: false)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(4),
                          shrinkWrap: true,
                          itemCount: conversationIndexs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return conversationItemWidget(chatService, conversationIndexs[index], (conversationIndex) {
                              // conversationIndexs.remove(conversationIndex);
                              conversationIndexs.removeAt(index);
                              setState(() {});
                            });
                          },
                        ),
                ),
                ShakeAnimationWidget(
                    //抖动控制器
                    shakeAnimationController: _shakeAnimationController,
                    //微旋转的抖动
                    shakeAnimationType: ShakeAnimationType.RoateShake,
                    //设置不开启抖动
                    isForward: false,
                    //默认为 0 无限执行
                    shakeCount: 0,
                    //抖动的幅度 取值范围为[0,1]
                    shakeRange: 0.03,
                    //执行抖动动画的子Widget
                    child: GestureDetector(
                      child: Container(
                        width: 400,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: ThemeColor.primaryColor.withOpacity(.6),
                            borderRadius: const BorderRadiusDirectional.all(Radius.circular(50))),
                        child: Row(
                          children: [
                            Text(S.current.ask_anything, style: const TextStyle(fontSize: 15, color: Colors.white70)),
                            const Spacer(),
                            const Icon(Icons.edit, color: Colors.white70)
                          ],
                        ),
                      ),
                      onTap: () {
                        Conversation conversation = Conversation.create();
                        conversation.title = S.current.ask_anything;
                        Navigation.navigatorChat(context, chatService, conversation);
                      },
                    ))
              ],
            ),
          ],
        ));
  }

  Widget conversationItemWidget(
      ChatService chatService, ConversationIndex conversationIndex, Function(ConversationIndex) deleteAction) {
    return SizedBox(
        child: ListTile(
      title: Text(conversationIndex.title, style: const TextStyle(overflow: TextOverflow.ellipsis)),
      horizontalTitleGap: 10,
      contentPadding: const EdgeInsets.fromLTRB(15, 0, 5, 0),
      splashColor: Colors.black45,
      onTap: () async {
        var id = conversationIndex.id;
        var conversation = chatService.getConversationById(id);
        if (conversation != null) {
          if (context.mounted) {
            setState(() {
              LocalStorageService().currentConversationId = id;
              if (Platform.isAndroid || Platform.isIOS) {
                Navigation.navigatorChat(context, chatService, conversation);
              } else {
                Navigation.navigator(context, ChatScreenPage(currentConversation: conversation));
              }
            });
          }
        }
      },
      trailing: PopupMenuButton(
        icon: const Icon(Icons.more_vert),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              value: 'edit',
              child: Text(S.current.edit),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(S.current.delete),
            ),
          ];
        },
        onSelected: (value) async {
          var conversation = chatService.getConversationById(conversationIndex.id);
          var bloc = BlocProvider.of<ConversationsBloc>(context);
          switch (value) {
            case 'edit':
              if (conversation == null) {
                break;
              }
              var newConversation = await showConversationDialog(context, true, conversation);
              if (newConversation != null) {
                await chatService.updateConversation(newConversation);
                setState(() {
                  bloc.add(const ConversationsRequested());
                });
              }
              break;
            case 'delete':
              var result = await showDeleteConfirmDialog(context);
              if (result == true) {
                bloc.add(ConversationDeleted(conversationIndex));
                deleteAction(conversationIndex);
              }
              break;
            default:
              break;
          }
        },
      ),
    ));
  }
}
