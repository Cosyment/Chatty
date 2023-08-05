import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:chatty/api/http_request.dart';
import 'package:chatty/event/event_bus.dart';
import 'package:chatty/event/event_message.dart';
import 'package:chatty/models/prompt.dart';
import 'package:chatty/util/ads_manager.dart';
import 'package:chatty/util/constants.dart';
import 'package:chatty/util/environment_config.dart';
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
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
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
    var conversationReachedLimit = LocalStorageService().conversationLimit;
    if (conversationReachedLimit >= Constants.DAILY_CONVERSATION_LIMIT) {
      var result = await showRewardConfirmDialog(context);
      if (result == true) {
        setState(() {
          showLoadingDialog(context);
        });
        AdsManager.loadRewardAd(callback: () {
          Navigator.pop(context);
        });
      }
      return true;
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
        appBar: CommonAppBar(conversation.title, currentConversation: conversation),
        body: SafeArea(
            child: Column(children: [
          // system message
          if (_showSystemMessage)
            Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [Expanded(child: SelectableText(conversation.systemMessage, maxLines: 5))],
                )),
          // loading indicator
          if (state.status == ChatStatus.loading) const LinearProgressIndicator(color: Colors.white30),
          // chat messages
          Expanded(
              child: ScrollConfiguration(
                  behavior: const ScrollBehavior(),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: (state.status == ChatStatus.loading) ? const NeverScrollableScrollPhysics() : null,
                    itemCount:
                        (state.status == ChatStatus.loading) ? conversation.messages.length + 1 : conversation.messages.length,
                    itemBuilder: (context, index) {
                      if ((state.status == ChatStatus.loading) && (index == conversation.messages.length)) {
                        return const SizedBox(height: 60);
                      } else {
                        return ChatMessageWidget(message: conversation.messages[index], isMarkdown: isMarkdown);
                      }
                    },
                  ))),
          // status bar
          ValueListenableBuilder<TextEditingValue>(
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
                            height: _showPromptPopup ? 210 : 24,
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.only(left: 16),
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.integration_instructions_outlined,
                                        size: 16,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                          'Limit：${min(TokenService.getEffectiveMessages(conversation, value.text).length, LocalStorageService().historyCount)}/${LocalStorageService().historyCount}',
                                          style: const TextStyle(fontSize: 12))
                                    ],
                                  ),
                                  const SizedBox(width: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.translate, size: 16, color: Colors.white70),
                                      const SizedBox(width: 2),
                                      Text('System: ${TokenService.getToken(conversation.systemMessage)}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: TokenService.getToken(conversation.systemMessage) >=
                                                      TokenService.getTokenLimit()
                                                  ? Theme.of(context).colorScheme.error
                                                  : null)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.input_outlined, size: 16, color: Colors.white70),
                                      const SizedBox(width: 2),
                                      Text('Input: ${TokenService.getToken(value.text)}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: TokenService.getToken(conversation.systemMessage) +
                                                          TokenService.getToken(value.text) >=
                                                      TokenService.getTokenLimit()
                                                  ? Theme.of(context).colorScheme.error
                                                  : null)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.history, size: 16, color: Colors.white70),
                                      const SizedBox(width: 2),
                                      Text('History: ${TokenService.getEffectiveMessagesToken(conversation, value.text)}',
                                          style: const TextStyle(fontSize: 12)),
                                    ],
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
                          width: inputBoxWidth! + 5,
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
                                        height: 40,
                                        child: Center(child: Text(_promptList[index].title, textAlign: TextAlign.center))),
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
              }),
          // chat input
          Container(
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 8),
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.lerp(Theme.of(context).colorScheme.background, Colors.white, 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        key: _inputGlobalKey,
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(hintText: S.current.send_a_message, border: InputBorder.none),
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
                                    color:
                                        TokenService.getToken(conversation.systemMessage) + TokenService.getToken(value.text) >=
                                                TokenService.getTokenLimit()
                                            ? Theme.of(context).colorScheme.error
                                            : null,
                                    onPressed:
                                        (state.status == ChatStatus.loading) || (value.text.isEmpty || value.text.trim().isEmpty)
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
              )),
        ])),
      ),
    );
  }
}
