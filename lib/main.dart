import 'dart:io';

import 'package:chatty/advert/advert_manager.dart';
import 'package:chatty/api/http_request.dart';
import 'package:chatty/event/event_bus.dart';
import 'package:chatty/event/event_message.dart';
import 'package:chatty/util/constants.dart';
import 'package:chatty/util/environment_config.dart';
import 'package:chatty/util/platform_util.dart';
import 'package:chatty/widgets/theme_color.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';
import 'package:window_manager/window_manager.dart';

import '../generated/l10n.dart';
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

  if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux || Platform.isFuchsia) {
    if (!kIsWeb) {
      await windowManager.ensureInitialized();
    }
    WindowOptions windowOptions = const WindowOptions(
      size: Size(950, 650),
      minimumSize: Size(950, 650),
      center: true,
      backgroundColor: Colors.transparent,
      windowButtonVisibility: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } else {
    if (Platform.isIOS) {
      LocalStorageService().isPad = await PlatformUtil.isPad;
    }
    AdvertManager().initial();
  }

  var lastAppLaunchTime = LocalStorageService().appLaunchTime;
  if (lastAppLaunchTime?.isNotEmpty == true) {
    DateTime launchTime = DateTime.parse(lastAppLaunchTime!);
    DateTime currentDate = DateTime.now();
    if ((launchTime.day < currentDate.day) || launchTime.month < currentDate.month || launchTime.year < currentDate.year) {
      LocalStorageService().conversationLimit = 0;
    }
  } else {
    LocalStorageService().conversationLimit = 0;
  }

  checkMembershipInfo();

  LocalStorageService().updateAppLaunchTime = DateTime.now();

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

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: ThemeColor.backgroundColor, statusBarColor: Colors.transparent));

    if (PlatformUtil.isMobile) {
      //友盟初始化
      UmengCommonSdk.initCommon('64979b89a1a164591b38ceda' /*Android AppKey*/, '6496a96887568a379b5ce593' /*ios AppKey*/,
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
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              supportedLocales: S.delegate.supportedLocales,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.dark(brightness: Brightness.dark, primary: ThemeColor.primaryColor),
                appBarTheme: AppBarTheme(backgroundColor: ThemeColor.appBarBackgroundColor),
                scaffoldBackgroundColor: ThemeColor.backgroundColor,
                popupMenuTheme: PopupMenuThemeData(color: ThemeColor.popupBackground, elevation: 10),
                dialogBackgroundColor: ThemeColor.dialogBackground,
                textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.white70),
                inputDecorationTheme: InputDecorationTheme(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ThemeColor.selectColor),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ThemeColor.textColor),
                  ),
                ),
                textButtonTheme: const TextButtonThemeData(
                    style: ButtonStyle(foregroundColor: MaterialStatePropertyAll<Color>(Colors.white54))),
                elevatedButtonTheme: const ElevatedButtonThemeData(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(Colors.black38),
                        foregroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                        textStyle: MaterialStatePropertyAll<TextStyle>(TextStyle(color: Colors.white)))),
                listTileTheme: const ListTileThemeData(textColor: Colors.white70, selectedColor: Colors.white),
              ),
              debugShowCheckedModeBanner: false,
              home: const MainScreen(),
            )));
  }
}

void checkMembershipInfo() async {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  if (!await inAppPurchase.isAvailable()) return;
  inAppPurchase.restorePurchases();
  inAppPurchase.purchaseStream.listen((List<PurchaseDetails> purchaseDetailsList) {
    if (purchaseDetailsList.isEmpty) {
      LocalStorageService().currentMembershipProductId = '';
      LocalStorageService().remove(LocalStorageService.prefMembershipProductId);
    }

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.restored) {
        // 已开通会员
        LocalStorageService().currentMembershipProductId = purchaseDetails.productID;
      }
    }
  }, onDone: () {
    debugPrint('purchase done');
  }, onError: (Object error) {
    debugPrint('purchase error $error');
  });
}

void registerNetWorkListening() {
  if (!kIsWeb && Platform.isIOS) {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
        initialConfiguration();
      }
    });
  } else {
    initialConfiguration();
  }
}

void initialConfiguration() async {
  if (!LocalStorageService().isCustomApiKey) {
    var secretKey = await HttpRequest.request<SecretKey>(Urls.querySecretKey, (jsonData) => SecretKey.fromJson(jsonData));
    LocalStorageService().apiKey = secretKey.apiKey;
  }

  if (LocalStorageService().currentLanguageCode != null) {
    S.delegate.load(Locale(LocalStorageService().currentLanguageCode ?? 'en'));
    EventBus.getDefault().post(EventMessage<EventType>(EventType.CHANGE_LANGUAGE));
  } else {
    LocalStorageService().languageCode = PlatformDispatcher.instance.locale.languageCode;
  }

  getCurrentCountry();
}

void getCurrentCountry() async {
  dynamic result = await HttpRequest.requestJson(Urls.queryCountry);
  debugPrint('current country: $result');
  LocalStorageService().currentCountryCode = result['countryCode'];

  getDomain();
}

void getDomain() async {
  var domains =
      await HttpRequest.request<Domain>(Urls.queryDomain, params: {'type': '0'}, (jsonData) => Domain.fromJson(jsonData));
  List<Domain> domainList = domains;
  if (LocalStorageService().apiHost == '' && domainList != null && domainList.isNotEmpty) {
    if (LocalStorageService().isChina) {
      LocalStorageService().apiHost = domainList.where((element) => element.type != 0).first.hostname;
    } else {
      LocalStorageService().apiHost = domainList.where((element) => element.type == 0).first.hostname;
    }
  }
}
