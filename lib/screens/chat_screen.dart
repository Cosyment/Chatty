import 'dart:io';
import 'dart:math';

import 'package:chatbotty/models/prompt.dart';
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
  final List<Prompt> _promptList = [
    Prompt(
        title: '充当 Linux 终端',
        promptContent:
            '我想让你充当 Linux 终端。我将输入命令，您将回复终端应显示的内容。我希望您只在一个唯一的代码块内回复终端输出，而不是其他任何内容。不要写解释。除非我指示您这样做，否则不要键入命令。当我需要用英语告诉你一些事情时，我会把文字放在中括号内[就像这样]。我的第一个命令是 pwd'),
    Prompt(
        title: '充当英语翻译和改进者',
        promptContent:
            '我希望你能担任英语翻译、拼写校对和修辞改进的角色。我会用任何语言和你交流，你会识别语言，将其翻译并用更为优美和精炼的英语回答我。请将我简单的词汇和句子替换成更为优美和高雅的表达方式，确保意思不变，但使其更具文学性。请仅回答更正和改进的部分，不要写解释。我的第一句话是“how are you ?”，请翻译它。'),
    Prompt(
        title: '充当论文润色者',
        promptContent:
            '请你充当一名论文编辑专家，在论文评审的角度去修改论文摘要部分，使其更加流畅，优美。下面是具体要求：1.能让读者快速获得文章的要点或精髓，让文章引人入胜；能让读者了解全文中的重要信息、分析和论点；帮助读者记住论文的要点2.字数限制在300字以下3.请你在摘要中明确指出您的模型和方法的创新点，强调您的贡献。4.用简洁、明了的语言描述您的方法和结果，以便评审更容易理解论文下文是论文的摘要部分，请你修改它：'),
    Prompt(
        title: '充当英翻中',
        promptContent:
            '下面我让你来充当翻译家，你的目标是把任何语言翻译成中文，请翻译时不要带翻译腔，而是要翻译得自然、流畅和地道，使用优美和高雅的表达方式。请翻译下面这句话：“how are you ?”'),
    Prompt(
        title: '担任面试官',
        promptContent:
            '示例：Java 后端开发工程师、React 前端开发工程师、全栈开发工程师、iOS 开发工程师、Android开发工程师等。 回复截图请看这我想让你担任Android开发工程师面试官。我将成为候选人，您将向我询问Android开发工程师职位的面试问题。我希望你只作为面试官回答。不要一次写出所有的问题。我希望你只对我进行采访。问我问题，等待我的回答。不要写解释。像面试官一样一个一个问我，等我回答。我的第一句话是“面试官你好”'),
    Prompt(
        title: '担任产品经理',
        promptContent:
            '请确认我的以下请求。请您作为产品经理回复我。我将会提供一个主题，您将帮助我编写一份包括以下章节标题的PRD文档：主题、简介、问题陈述、目标与目的、用户故事、技术要求、收益、KPI指标、开发风险以及结论。我的需求是：做一个赛博朋克的网站首页。'),
    Prompt(
        title: '充当“电影/书籍/任何东西”中的“角色”',
        promptContent:
            '角色可自行替换我希望你表现得像西游记中的唐三藏。我希望你像唐三藏一样回应和回答。不要写任何解释。必须以唐三藏的语气和知识范围为基础。我的第一句话是“你好”'),
    Prompt(
        title: '充当花哨的标题生成器',
        promptContent:
            '我想让你充当一个花哨的标题生成器。我会用逗号输入关键字，你会用花哨的标题回复。我的第一个关键字是 api、test、automation'),
  ];
  bool _isPromptMessage = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
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

    if(_isPromptMessage){
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
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent - 10,
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn);
    }, onDone: () {
      BlocProvider.of<ChatBloc>(context).add(ChatStreamEnded(conversation));
      BlocProvider.of<ConversationsBloc>(context)
          .add(const ConversationsRequested());
    });

    _isPromptMessage = false;
    report(newMessage);
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
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100), curve: Curves.bounceIn);
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
                    value.text == '/') {
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
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                          child: AnimatedSlide(
                              offset: Offset(0, _showPromptPopup ? 0 : 0),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.linear,
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
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  margin:
                                      const EdgeInsets.fromLTRB(12, 10, 12, 0),
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
                                handleSend(context, conversation);
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
