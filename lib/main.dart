import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chatbotty/api/http_request.dart';
import 'package:chatbotty/util/constants.dart';
import 'package:chatbotty/util/environment_config.dart';
import 'package:chatbotty/util/platform_util.dart';
import 'package:chatbotty/widgets/theme_color.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:umeng_common_sdk/umeng_common_sdk.dart';
import 'package:window_manager/window_manager.dart';

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

  if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    if (!kIsWeb) {
      await windowManager.ensureInitialized();
    }
    WindowOptions windowOptions = const WindowOptions(
      size: Size(900, 600),
      minimumSize: Size(900, 600),
      center: true,
      backgroundColor: Colors.transparent,
      windowButtonVisibility: true,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(App(chatService: chatService));

  // BindingBase.debugZoneErrorsAreFatal = true;
  // runZonedGuarded(
  //   () => {runApp(App(chatService: chatService))},
  //   (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  // );

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

    if (PlatformUtil.isMobile) {
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
                Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
                Locale('ja'),
                Locale('ko')
              ],
              theme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.dark,
                  cardColor: ThemeColor.primaryColor,
                  dialogBackgroundColor: ThemeColor.backgroundColor,
                  scaffoldBackgroundColor: ThemeColor.backgroundColor,
                  dialogTheme: DialogTheme(backgroundColor: ThemeColor.backgroundColor),
                  textButtonTheme: const TextButtonThemeData(
                      style: ButtonStyle(foregroundColor: MaterialStatePropertyAll<Color>(Colors.white30))),
                  elevatedButtonTheme: const ElevatedButtonThemeData(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.black38),
                          foregroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                          textStyle: MaterialStatePropertyAll<TextStyle>(TextStyle(color: Colors.white)))),
                  appBarTheme: AppBarTheme(backgroundColor: ThemeColor.appBarBackgroundColor),
                  listTileTheme: const ListTileThemeData(
                      // tileColor: Colors.black12,
                      // selectedTileColor: Colors.blue,
                      textColor: Colors.white70,
                      selectedColor: Colors.white),
                  primaryColor: ThemeColor.backgroundColor),
              debugShowCheckedModeBanner: false,
              home: const ConversationScreenPage(),
            )));
  }
}

void registerNetWorkListening() {
  if (!kIsWeb && Platform.isIOS) {
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
  if (!LocalStorageService().isCustomApiKey) {
    var secretKey = await HttpRequest.request<SecretKey>(
        Urls.querySecretKey, (jsonData) => SecretKey.fromJson(jsonData));
    LocalStorageService().apiKey = secretKey.apiKey;
  }

  getCurrentCountry();
}

void getCurrentCountry() async {
  dynamic result = await HttpRequest.requestJson(Urls.queryCountry);
  LocalStorageService().currentCountryCode = result['countryCode'];
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
