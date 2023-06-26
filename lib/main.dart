import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import 'api/openai_api.dart';
import 'bloc/blocs.dart';
import 'screens/screens.dart';
import 'services/chat_service.dart';
import 'services/local_storage_service.dart';
import 'util/extend_http_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService().init();
  Bloc.observer = const AppBlocObserver();
  final openAiApi = OpenAiApi(SafeHttpClient(http.Client()));
  final chatService = ChatService(apiServer: openAiApi);

  // TODO: init token service in background to speed up ChatScreen on the first load
  runZonedGuarded(
    () => runApp(App(chatService: chatService)),
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
  BindingBase.debugZoneErrorsAreFatal = false;
}

class App extends StatefulWidget {
  const App({super.key, required this.chatService});

  final ChatService chatService;

  @override
  State<StatefulWidget> createState() => _AppState(chatService);
}

class _AppState extends State<App> {
  _AppState(this.chatService);

  final ChatService chatService;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid || Platform.isIOS) {
      //友盟初始化
      UmengCommonSdk.initCommon('64979b89a1a164591b38ceda' /*Android AppKey*/,
          '6496a96887568a379b5ce593' /*ios AppKey*/, 'Chatbotty');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
        value: chatService,
        child: BlocProvider(
            create: (context) => ConversationsBloc(
                  chatService: context.read<ChatService>(),
                )..add(const ConversationsRequested()),
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              supportedLocales: [Locale('en'), Locale('zh')],
              theme: ThemeData.dark(useMaterial3: true),
              home: const ConversationScreenPage(),
            )));
  }
}
