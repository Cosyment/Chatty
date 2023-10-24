import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:chatty/advert/advert_manager.dart';
import 'package:chatty/api/http_request.dart';
import 'package:chatty/event/event_bus.dart';
import 'package:chatty/event/event_message.dart';
import 'package:chatty/models/prompt.dart';
import 'package:chatty/screens/premium_screen.dart';
import 'package:chatty/util/constants.dart';
import 'package:chatty/util/environment_config.dart';
import 'package:chatty/util/navigation.dart';
import 'package:chatty/util/platform_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import '../bloc/blocs.dart';
import '../generated/l10n.dart';
import '../models/models.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import '../services/token_service.dart';
import '../widgets/common_stateful_widget.dart';
import '../widgets/theme_color.dart';
import '../widgets/widgets.dart';

class ChatScreenPage extends CommonStatefulWidget {
  final Conversation? currentConversation;

  ChatScreenPage({super.key, this.currentConversation}) {
    if (currentConversation != null) {
      EventBus.getDefault().post(EventMessage<Conversation>(currentConversation!));
    }
  }

  @override
  State<StatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreenPage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late ScrollController _scrollController;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  final bool _showSystemMessage = false;
  late bool _initScroll = true;
  late bool _showPromptPopup = false;
  late List<Prompt> _promptList = [];
  bool _isPromptMessage = false;
  final GlobalKey _inputGlobalKey = GlobalKey();

  Future<bool?> showRewardConfirmDialog(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            title: S.current.reminder,
            content: S.current.conversation_chat_reached_limit,
          );
        },
      );

  Future<void> showLoadingDialog(BuildContext context) => showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: Lottie.asset('assets/reward_loading.json', repeat: true));
      });

  @override
  void initState() {
    _scrollController = ScrollController();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
    initialPrompts();
    EventBus.getDefault().register<EventMessage<EventType>>(this, (event) {
      if (event.data == EventType.CHANGE_LANGUAGE) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    EventBus.getDefault().unregister(this);
    super.dispose();
  }

  void initialPrompts() async {
    var promptListJson = LocalStorageService().promptListJson;
    if (promptListJson.isNotEmpty) {
      List list = jsonDecode(promptListJson);
      _promptList = list.map((e) => Prompt.fromJson(e)).toList();
    } else {
      _promptList = await HttpRequest.request<Prompt>(
          Urls.queryPromptByLanguageCode,
          params: {'language': PlatformDispatcher.instance.locale.languageCode},
          (p0) => Prompt.fromJson(p0));
      LocalStorageService().promptListJson = jsonEncode(_promptList);
    }
  }

  void handleSend(BuildContext context, Conversation conversation) async {
    if (await _hasConversationLimit(context)) return;

    if (LocalStorageService().apiKey == '') {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(S.current.please_add_your_api_key)));
      return;
    }

    if (TokenService.getToken(conversation.systemMessage) + TokenService.getToken(_textEditingController.text) >=
        TokenService.getTokenLimit()) return;
    var chatService = context.read<ChatService>();
    var newMessage = ConversationMessage('user', _textEditingController.text);

    if (_isPromptMessage) {
      conversation.systemMessage = _textEditingController.text;
    }

    _textEditingController.text = '';
    if (conversation.messages.isNotEmpty && conversation.messages.last.role == 'user') {
      conversation.messages.last = newMessage;
    } else {
      conversation.messages.add(newMessage);
    }
    BlocProvider.of<ChatBloc>(context).add(ChatStreamStarted(conversation));
    chatService.getResponseStreamFromServer(conversation).listen((conversation) {
      BlocProvider.of<ChatBloc>(context).add(ChatStreaming(conversation, conversation.lastUpdated));
      _scrollController.animateTo(_scrollController.position.maxScrollExtent - 10,
          duration: const Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
    }, onDone: () {
      BlocProvider.of<ChatBloc>(context).add(ChatStreamEnded(conversation));
      BlocProvider.of<ConversationsBloc>(context).add(const ConversationsRequested());
    });

    _isPromptMessage = false;
    if (PlatformUtil.isMobile) {
      // report(newMessage);
    }
  }

  Future<bool> _hasConversationLimit(BuildContext context) async {
    if (LocalStorageService().isMembershipUser()) return false;
    if (PlatformUtil.isMobile) {
      var conversationReachedLimit = LocalStorageService().conversationLimit;
      if (conversationReachedLimit >= AdvertManager.DAILY_CONVERSATION_LIMIT) {
        // if (conversationReachedLimit >= 2) {
        var result = await showRewardConfirmDialog(context);
        if (result == true) {
          if (context.mounted) {
            showLoadingDialog(context);
          }
          AdvertManager().showReward((msg) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            if (msg?.isNotEmpty == true) {
              scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(msg!)));
            }
          });
        }
        return true;
      }
      return false;
    }
    return false;
  }

  void report(ConversationMessage message) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var reportMap = {
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
      'language': Platform.localeName,
      'channel': EnvironmentConfig.APP_CHANNEL,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'role': message.role,
      'content': message.content,
      'createTime': HttpDate.format(DateTime.timestamp())
    };

    UmengCommonSdk.onEvent("Chat Message", reportMap);
  }

  void handleRefresh(BuildContext context, Conversation conversation) async {
    if (await _hasConversationLimit(context)) return;

    if (LocalStorageService().apiKey == '') {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(S.current.please_add_your_api_key)));
      return;
    }

    var chatService = context.read<ChatService>();
    if (conversation.messages.last.role == 'Chatty') {
      conversation.messages.removeLast();
    }
    BlocProvider.of<ChatBloc>(context).add(ChatStreamStarted(conversation));
    chatService.getResponseStreamFromServer(conversation).listen((conversation) {
      BlocProvider.of<ChatBloc>(context).add(ChatStreaming(conversation, conversation.lastUpdated));
      _scrollController.animateTo(_scrollController.position.maxScrollExtent - 10,
          duration: const Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
    }, onDone: () {
      BlocProvider.of<ChatBloc>(context).add(ChatStreamEnded(conversation));
      BlocProvider.of<ConversationsBloc>(context).add(const ConversationsRequested());
    });
  }

  Future<Conversation?> showConversationDialog(BuildContext context, bool isEdit, Conversation conversation) =>
      showDialog<Conversation?>(
          context: context,
          builder: (context) {
            return ConversationEditDialog(conversation: conversation, isEdit: isEdit);
          });

  Future<bool?> showClearConfirmDialog(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            title: S.current.clear_conversation,
            content: S.current.clear_conversation_tips,
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChatBloc>().state;
    final conversationState = context.watch<ConversationsBloc>().state;
    // var conversation = state.initialConversation;
    var isMarkdown = LocalStorageService().renderMode == 'markdown';
    double? inputBoxWidth = 10.0;

    var conversation = widget.currentConversation ?? state.initialConversation;

    if (state.status == ChatStatus.failure) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(conversation.error),
            action: SnackBarAction(
              label: S.current.resend,
              onPressed: () {
                BlocProvider.of<ChatBloc>(context).add(ChatSubmitted(conversation));
              },
            ),
          ),
        );
      });
    }

    if (state.status == ChatStatus.success) {
      LocalStorageService().conversationLimit += 1;
    }

    if (conversationState.status == ConversationsStatus.clear) {
      if (conversation.messages.isNotEmpty) {
        var chatService = context.read<ChatService>();
        conversation = chatService.getConversationById(LocalStorageService().currentConversationId)!;
      }
    }

    if (_initScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100), curve: Curves.linear);
        _initScroll = false;
        // });
      });
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      inputBoxWidth = _inputGlobalKey.currentContext?.size?.width;
    });

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: _appBar(conversation),
        body: Stack(
          fit: StackFit.passthrough,
          alignment: AlignmentDirectional.topCenter,
          children: [
            _gaussianWidget(),
            Column(children: [
              // system message
              if (_showSystemMessage) _systemMessage(conversation),
              // loading indicator
              if (state.status == ChatStatus.loading) const LinearProgressIndicator(color: Colors.white30),
              // chat messages
              _messageContent(state, conversation, isMarkdown),
              // status bar
              _valueBuilder(inputBoxWidth!),
              _bottomInputBox(state, conversation)
            ])
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(conversation) {
    return CommonAppBar(
      conversation.title,
      currentConversation: conversation,
      actionWidgets: [
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'edit',
                child: Text(S.current.edit),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Text(S.current.clear_conversation),
              ),
            ];
          },
          onSelected: (value) async {
            var chatService = context.read<ChatService>();
            var conversationsBloc = BlocProvider.of<ConversationsBloc>(context);
            switch (value) {
              case 'edit':
                var newConversation = await showConversationDialog(context, true, widget.currentConversation!);
                if (newConversation != null) {
                  widget.currentConversation?.lastUpdated = DateTime.now();
                  setState(() {
                    // widget.title = newConversation.title;
                    widget.currentConversation?.title = newConversation.title;
                  });

                  await chatService.updateConversation(newConversation);

                  var chatBloc = ChatBloc(chatService: chatService, initialConversation: newConversation);

                  chatBloc.add(ChatLastUpdatedChanged(newConversation, newConversation.lastUpdated));
                  conversationsBloc.add(const ConversationsRequested());
                }
                break;
              case 'clear':
                var result = await showClearConfirmDialog(context);
                if (result == true) {
                  widget.currentConversation?.messages = [];
                  widget.currentConversation?.lastUpdated = DateTime.now();

                  await chatService.updateConversation(widget.currentConversation!);

                  var chatBloc = ChatBloc(chatService: chatService, initialConversation: widget.currentConversation!);

                  chatBloc.add(ChatLastUpdatedChanged(widget.currentConversation!, widget.currentConversation!.lastUpdated));
                  conversationsBloc.add(const ConversationsCleared());
                }
                break;
              default:
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _systemMessage(conversation) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [Expanded(child: SelectableText(conversation.systemMessage, maxLines: 5))],
        ));
  }

  Widget _messageContent(state, conversation, isMarkdown) {
    return Expanded(
        child: ScrollConfiguration(
            behavior: const ScrollBehavior(),
            child: ListView.builder(
              controller: _scrollController,
              physics: (state.status == ChatStatus.loading) ? const NeverScrollableScrollPhysics() : null,
              itemCount: (state.status == ChatStatus.loading) ? conversation.messages.length + 1 : conversation.messages.length,
              itemBuilder: (context, index) {
                if ((state.status == ChatStatus.loading) && (index == conversation.messages.length)) {
                  return const SizedBox(height: 60);
                } else {
                  return ChatMessageWidget(message: conversation.messages[index], isMarkdown: isMarkdown);
                }
              },
            )));
  }

  Widget _valueBuilder(double inputBoxWidth) {
    return ValueListenableBuilder<TextEditingValue>(
        valueListenable: _textEditingController,
        builder: (context, value, child) {
          if (value.text.isNotEmpty && value.text.length == 1 && value.text == '/' && _promptList.isNotEmpty) {
            _showPromptPopup = true;
          } else {
            _showPromptPopup = false;
          }

          return Stack(alignment: AlignmentDirectional.center, fit: StackFit.loose, children: [
            Positioned(
                child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.linear,
                    child: SizedBox(
                      height: _showPromptPopup ? 210 : 30,
                      child: Container(
                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.only(left: 16),
                        child: Row(
                          children: [
                            const Text(
                              '今日聊天次数仅剩5次,订阅会员即可享受无限聊天次数',
                              style: TextStyle(color: Colors.white30, fontSize: 10),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigation.navigator(context, const PremiumScreenPage());
                              },
                              child: const Text(' 立即订阅>', style: TextStyle(color: Colors.yellow, fontSize: 10)),
                            )
                          ],
                        ),
                      ),
                    ))),
            AnimatedPositioned(
                bottom: _showPromptPopup ? 0 : -200,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
                child: Container(
                    constraints: BoxConstraints(minHeight: 10, maxHeight: _showPromptPopup ? 400 : 10),
                    width: inputBoxWidth + 5,
                    height: 200.0,
                    decoration: BoxDecoration(
                      color: Color.lerp(Theme.of(context).colorScheme.background, Colors.white, 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.fromLTRB(12, 10, 49, 0),
                    child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _promptList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              child: SizedBox(
                                  height: 40, child: Center(child: Text(_promptList[index].title, textAlign: TextAlign.center))),
                              onTap: () {
                                _textEditingController.text = _promptList[index].promptContent;
                                _textEditingController.selection =
                                    TextSelection.fromPosition(TextPosition(offset: _textEditingController.text.length));
                                _isPromptMessage = true;
                              });
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(height: 1.0, color: Colors.white10))))
          ]);
        });
  }

  Widget _bottomInputBox(state, conversation) {
    return Container(
        padding: const EdgeInsets.only(left: 12, top: 4, bottom: 8),
        alignment: Alignment.centerRight,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.lerp(ThemeColor.backgroundColor, Colors.white, 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  key: _inputGlobalKey,
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: S.current.send_a_message,
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            border: InputBorder.none),
                        controller: _textEditingController,
                        focusNode: _focusNode,
                        minLines: 1,
                        maxLines: 3,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (value) async {
                          if ((state.status != ChatStatus.loading) && (value.isNotEmpty && value.trim().isNotEmpty)) {
                            handleSend(context, conversation);
                          }
                        },
                      ),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _textEditingController,
                        builder: (context, value, child) {
                          return IconButton(
                              icon: const Icon(Icons.send),
                              color: TokenService.getToken(conversation.systemMessage) + TokenService.getToken(value.text) >=
                                      TokenService.getTokenLimit()
                                  ? Theme.of(context).colorScheme.error
                                  : null,
                              onPressed: (state.status == ChatStatus.loading) || (value.text.isEmpty || value.text.trim().isEmpty)
                                  ? null
                                  : () => handleSend(context, conversation));
                        }),
                  ],
                ),
              ),
            ),
            IconButton(
                icon: const Icon(Icons.refresh),
                iconSize: 35,
                onPressed: (state.status == ChatStatus.loading) || (conversation.messages.isEmpty)
                    ? null
                    : () => handleRefresh(context, conversation))
          ],
        ));
  }

  Widget _gaussianWidget() {
    return Stack(children: [
      Image.asset('assets/images/bg.webp', fit: BoxFit.cover),
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: Container(
            color: Colors.black12,
          ),
        ),
      )
    ]);
  }
}
