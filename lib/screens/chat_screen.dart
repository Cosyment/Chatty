import 'dart:io';
import 'dart:math';

import 'package:chatbotty/api/http_request.dart';
import 'package:chatbotty/models/prompt.dart';
import 'package:chatbotty/util/constants.dart';
import 'package:chatbotty/util/environment_config.dart';
import 'package:chatbotty/util/platform_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import '../bloc/blocs.dart';
import '../models/models.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import '../services/token_service.dart';
import '../widgets/widgets.dart';
import 'screens.dart';

class ChatScreenPage extends StatelessWidget {
  const ChatScreenPage({super.key});

  static Route<void> route(Conversation initialConversation) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => BlocProvider(
        create: (context) => ChatBloc(
          chatService: context.read<ChatService>(),
          initialConversation: initialConversation,
        ),
        child: TabletScreenPage(
            sidebar:
                ConversationScreen(selectedConversation: initialConversation),
            body: const ChatScreen()),
      ),
      transitionDuration: Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == ChatStatus.success,
      listener: (context, state) => Navigator.of(context).pop(),
      child: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late ScrollController _scrollController;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  final bool _showSystemMessage = false;
  late bool _initScroll = true;
  late bool _showPromptPopup = false;
  final List<Prompt> _promptList = [];
  bool _isPromptMessage = false;

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
    var prompts = await HttpRequest.request<Prompt>(
        Urls.queryPromptByCountryCode,
        params: {
          'countryCode': LocalStorageService().currentCountryCode.toString()
        },
        (p0) => Prompt.fromJson(p0));
    if (prompts != null && prompts is List && prompts.isNotEmpty) {
      _promptList.clear();
      for (var element in prompts) {
        _promptList.add(
            Prompt(title: element.title, promptContent: element.promptContent));
      }
    }
  }

  void handleSend(BuildContext context, Conversation conversation) {
    if (LocalStorageService().apiKey == '') {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context)!.please_add_your_api_key)));
      return;
    }

    if (TokenService.getToken(conversation.systemMessage) +
            TokenService.getToken(_textEditingController.text) >=
        TokenService.getTokenLimit()) return;
    var chatService = context.read<ChatService>();
    var newMessage = ConversationMessage('user', _textEditingController.text);

    if (_isPromptMessage) {
      conversation.systemMessage = _textEditingController.text;
    }

    _textEditingController.text = '';
    if (conversation.messages.isNotEmpty &&
        conversation.messages.last.role == 'user') {
      conversation.messages.last = newMessage;
    } else {
      conversation.messages.add(newMessage);
    }
    BlocProvider.of<ChatBloc>(context).add(ChatStreamStarted(conversation));
    chatService.getResponseStreamFromServer(conversation).listen(
        (conversation) {
      BlocProvider.of<ChatBloc>(context)
          .add(ChatStreaming(conversation, conversation.lastUpdated));
      _scrollController.animateTo(_scrollController.position.maxScrollExtent - 10,
          duration: const Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
    }, onDone: () {
      BlocProvider.of<ChatBloc>(context).add(ChatStreamEnded(conversation));
      BlocProvider.of<ConversationsBloc>(context).add(const ConversationsRequested());
    });

    _isPromptMessage = false;
    if (PlatformUtl.isMobile) {
      report(newMessage);
    }
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

  void handleRefresh(BuildContext context, Conversation conversation) {
    if (LocalStorageService().apiKey == '') {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context)!.please_add_your_api_key)));
      return;
    }

    var chatService = context.read<ChatService>();
    if (conversation.messages.last.role == 'Chatbotty') {
      conversation.messages.removeLast();
    }
    BlocProvider.of<ChatBloc>(context).add(ChatStreamStarted(conversation));
    chatService.getResponseStreamFromServer(conversation).listen(
        (conversation) {
      BlocProvider.of<ChatBloc>(context)
          .add(ChatStreaming(conversation, conversation.lastUpdated));
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent - 10,
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn);
    }, onDone: () {
      BlocProvider.of<ChatBloc>(context).add(ChatStreamEnded(conversation));
      BlocProvider.of<ConversationsBloc>(context)
          .add(const ConversationsRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChatBloc>().state;
    final conversationState = context.watch<ConversationsBloc>().state;
    var conversation = state.initialConversation;
    var isMarkdown = LocalStorageService().renderMode == 'markdown';

    if (state.status == ChatStatus.failure) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(conversation.error),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.resend,
              onPressed: () {
                BlocProvider.of<ChatBloc>(context)
                    .add(ChatSubmitted(conversation));
              },
            ),
          ),
        );
      });
    }

    if (conversationState.status == ConversationsStatus.clear) {
      if (conversation.messages.isNotEmpty) {
        var chatService = context.read<ChatService>();
        conversation = chatService
            .getConversationById(LocalStorageService().currentConversationId)!;
      }
    }

    if (_initScroll && _scrollController.hasClients) {
      // _scrollController.animateTo(_scrollController.position.maxScrollExtent,
      //     duration: const Duration(milliseconds: 50), curve: Curves.linear);

      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      _initScroll = false;
    }

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: (PlatformUtl.isMobile)
            ? null
            : ChatScreenAppBar(currentConversation: conversation),
        body: SafeArea(
            child: Column(children: [
          // system message
          if (_showSystemMessage)
            Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                        child: SelectableText(conversation.systemMessage,
                            maxLines: 5))
                  ],
                )),
          // loading indicator
          if (state.status == ChatStatus.loading)
            const LinearProgressIndicator(),
          // chat messages
          Expanded(
              child: ScrollConfiguration(
                  behavior: const ScrollBehavior(),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: (state.status == ChatStatus.loading)
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    itemCount: (state.status == ChatStatus.loading)
                        ? conversation.messages.length + 1
                        : conversation.messages.length,
                    itemBuilder: (context, index) {
                      if ((state.status == ChatStatus.loading) &&
                          (index == conversation.messages.length)) {
                        return const SizedBox(height: 60);
                      } else {
                        return ChatMessageWidget(
                            message: conversation.messages[index],
                            isMarkdown: isMarkdown);
                      }
                    },
                  ))),
          // status bar
          ValueListenableBuilder<TextEditingValue>(
              valueListenable: _textEditingController,
              builder: (context, value, child) {
                if (value.text.isNotEmpty &&
                    value.text.length == 1 &&
                    value.text == '/' &&
                    _promptList.isNotEmpty) {
                  _showPromptPopup = true;
                } else {
                  _showPromptPopup = false;
                }

                return Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    fit: StackFit.loose,
                    children: [
                      Positioned(
                          child: SizedBox(
                        height: 24,
                        child: Container(
                          padding: const EdgeInsets.only(left: 16),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.history,
                                      size: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  const SizedBox(width: 8),
                                  Text(
                                      '${min(TokenService.getEffectiveMessages(conversation, value.text).length, LocalStorageService().historyCount)}/${LocalStorageService().historyCount}',
                                      style: const TextStyle(fontSize: 12))
                                ],
                              ),
                              const SizedBox(width: 20),
                              Row(
                                children: [
                                  Icon(Icons.translate,
                                      size: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  const SizedBox(width: 8),
                                  Text(
                                      'System: ${TokenService.getToken(conversation.systemMessage)}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: TokenService.getToken(
                                                      conversation
                                                          .systemMessage) >=
                                                  TokenService.getTokenLimit()
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .error
                                              : null)),
                                  const SizedBox(width: 8),
                                  Text(
                                      'Input: ${TokenService.getToken(value.text)}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: TokenService.getToken(
                                                          conversation
                                                              .systemMessage) +
                                                      TokenService.getToken(
                                                          value.text) >=
                                                  TokenService.getTokenLimit()
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .error
                                              : null)),
                                  const SizedBox(width: 8),
                                  Text(
                                      'History: ${TokenService.getEffectiveMessagesToken(conversation, value.text)}',
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              )
                            ],
                          ),
                        ),
                      )),
                      AnimatedOpacity(
                          opacity: _showPromptPopup ? 1 : 0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                          child: AnimatedSlide(
                              offset: Offset(0, _showPromptPopup ? 0 : 300),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease,
                              child: Container(
                                  constraints: BoxConstraints(
                                      minHeight: 10,
                                      maxHeight: _showPromptPopup ? 200 : 10),
                                  decoration: BoxDecoration(
                                    color: Color.lerp(
                                        Theme.of(context)
                                            .colorScheme
                                            .background,
                                        Colors.white,
                                        0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  margin:
                                      const EdgeInsets.fromLTRB(12, 10, 49, 0),
                                  child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: _promptList.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                            child: SizedBox(
                                                height: 40,
                                                child: Center(
                                                    child: Text(
                                                        _promptList[index]
                                                            .title,
                                                        textAlign:
                                                            TextAlign.center))),
                                            onTap: () {
                                              _textEditingController.text =
                                                  _promptList[index]
                                                      .promptContent;
                                              _textEditingController.selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset:
                                                              _textEditingController
                                                                  .text
                                                                  .length));
                                              _isPromptMessage = true;
                                            });
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                              const Divider(
                                                  height: 1.0,
                                                  color: Colors.white10)))))
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
                        color: Color.lerp(
                            Theme.of(context).colorScheme.background,
                            Colors.white,
                            0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .send_a_message,
                                  border: InputBorder.none),
                              controller: _textEditingController,
                              focusNode: _focusNode,
                              minLines: 1,
                              maxLines: 3,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (value) async {
                                if ((state.status != ChatStatus.loading) &&
                                    (value.isNotEmpty &&
                                        value.trim().isEmpty)) {
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
                                    color: TokenService.getToken(conversation
                                                    .systemMessage) +
                                                TokenService.getToken(
                                                    value.text) >=
                                            TokenService.getTokenLimit()
                                        ? Theme.of(context).colorScheme.error
                                        : null,
                                    onPressed: (state.status ==
                                                ChatStatus.loading) ||
                                            (value.text.isEmpty ||
                                                value.text.trim().isEmpty)
                                        ? null
                                        : () =>
                                            handleSend(context, conversation));
                              }),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.refresh),
                      iconSize: 35,
                      onPressed: (state.status == ChatStatus.loading) ||
                              (conversation.messages.isEmpty)
                          ? null
                          : () => handleRefresh(context, conversation))
                ],
              ))
        ])),
      ),
    );
  }
}
