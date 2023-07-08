import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chatbotty/api/http_request.dart';
import 'package:chatbotty/util/constants.dart';
import 'package:chatbotty/util/environment_config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import 'api/openai_api.dart';
import 'bloc/blocs.dart';
import 'models/domain.dart';
import 'models/secret_key.dart';
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

  registerNetWorkListening();
}

class App extends StatefulWidget {
  const App({super.key, required this.chatService});

  final ChatService chatService;

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        statusBarColor: Colors.transparent));

    if (Platform.isAndroid || Platform.isIOS) {
      //友盟初始化
      UmengCommonSdk.initCommon(
          '64979b89a1a164591b38ceda' /*Android AppKey*/,
          '6496a96887568a379b5ce593' /*ios AppKey*/,
          EnvironmentConfig.APP_CHANNEL);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
        value: widget.chatService,
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
              supportedLocales: const [
                Locale('en'),
                Locale.fromSubtags(languageCode: 'zh'),
                Locale.fromSubtags(
                    languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
                Locale('ja'),
                Locale('ko')
              ],
              theme: ThemeData.dark(useMaterial3: true),
              debugShowCheckedModeBanner: false,
              home: const ConversationScreenPage(),
            )));
  }
}

void registerNetWorkListening() {
  if (Platform.isIOS) {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        initialConfiguration();
      }
    });
  } else {
    initialConfiguration();
  }
}

void initialConfiguration() async {
  var secretKey = await HttpRequest.request<SecretKey>(
      Urls.querySecretKey, (jsonData) => SecretKey.fromJson(jsonData));
  LocalStorageService().apiKey = secretKey.apiKey;

  getCurrentCountry();
}

void getCurrentCountry() async {
  dynamic result = await HttpRequest.requestJson(Urls.queryCountry);
  LocalStorageService().currentCountry = result['countryCode'];
  getDomain();
}

void getDomain() async {
  var domains = await HttpRequest.request<Domain>(
      Urls.queryDomain,
      params: {'type': '0'},
      (jsonData) => Domain.fromJson(jsonData));
  List<Domain> domainList = domains;
  if (LocalStorageService().apiHost == '' &&
      domainList != null &&
      domainList.isNotEmpty) {
    if (LocalStorageService().isChina) {
      LocalStorageService().apiHost =
          domainList.where((element) => element.type != 0).first.hostname;
    } else {
      LocalStorageService().apiHost =
          domainList.where((element) => element.type == 0).first.hostname;
    }
  }
}
