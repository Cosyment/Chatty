import 'dart:io';

import 'package:chatty/api/http_request.dart';
import 'package:chatty/screens/screens.dart';
import 'package:chatty/widgets/common_stateful_widget.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../event/event_bus.dart';
import '../event/event_message.dart';
import '../generated/l10n.dart';
import '../models/domain.dart';
import '../services/local_storage_service.dart';
import '../util/constants.dart';
import '../util/environment_config.dart';
import '../util/navigation.dart';
import '../widgets/common_appbar.dart';

class MoreScreenPage extends CommonStatefulWidget {
  const MoreScreenPage({super.key});

  @override
  State<StatefulWidget> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreenPage> {
  final LinearGradient gradientColor = const LinearGradient(
      colors: [Color(0xFF2EC0FF), Color(0xFF5394FF), Color(0xFF7769FF), Color(0xFFB360EC), Color(0xFFEE56D9)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight);

  bool isEnableMarkdown = LocalStorageService().renderMode == 'markdown';

  String apiHost = LocalStorageService().apiHost;
  List<Domain> domainList = [
    Domain(hostname: 'https://api.openai.com', area: 'Official'),
    Domain(
      hostname: 'https://api.openai.com-proxy',
      area: 'Japan',
    )
  ];
  List<PopupMenuItem> domainPopupItems = [];
  List<PopupMenuItem> languageMenuItems = [];

  void fetchDomainList() async {
    domainList = await HttpRequest.request<Domain>(
        Urls.queryDomain, params: {'type': '0'}, (jsonData) => Domain.fromJson(jsonData), exception: (e) => {initialDomains()});
    if (context.mounted && domainList.isNotEmpty) {
      setState(() {
        initialDomains();
      });
    }
  }

  void initialDomains() {
    if (context.mounted) {
      if (domainPopupItems.isNotEmpty) {
        domainPopupItems.clear();
      }

      for (var domain in domainList) {
        domainPopupItems.add(CheckedPopupMenuItem(
          value: domain.hostname,
          checked: LocalStorageService().apiHost == domain.hostname,
          child: Text(domain.area),
        ));
      }
      setState(() {});
    }
  }

  void initialLanguages() {
    languageMenuItems.clear();
    for (var element in S.delegate.supportedLocales) {
      languageMenuItems.add(CheckedPopupMenuItem(
        value: element.toLanguageTag(),
        checked: LocalStorageService().currentLanguageCode == element.toLanguageTag(),
        child: Text(parseLanguage(element.toLanguageTag())),
      ));
    }
  }

  String parseLanguage(String? languageCode) {
    if (languageCode == 'zh' || languageCode == 'zh-CN') {
      return '简体中文';
    } else if (languageCode == 'zh-Hant' || languageCode == 'zh-TW' || languageCode == 'zh-HK') {
      return '繁體中文';
    } else if (languageCode == 'fr') {
      return 'Français';
    } else if (languageCode == 'ja') {
      return '日本語';
    } else if (languageCode == 'ko') {
      return '한국어';
    } else if (languageCode == 'ru') {
      return 'Русский язык';
    } else if (languageCode == 'de') {
      return 'Deutsch';
    } else if (languageCode == 'it') {
      return 'Italiano';
    } else if (languageCode == 'es') {
      return 'Español';
    }
    return 'English';
  }

  @override
  void initState() {
    fetchDomainList();
    initialLanguages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.passthrough, alignment: AlignmentDirectional.topCenter, children: [
      backgroundWidget(),
      Scaffold(
          appBar: CommonAppBar(
            S.current.more,
          ),
          body: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),

              GestureDetector(
                child: Container(
                    height: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        gradient: gradientColor, borderRadius: const BorderRadiusDirectional.all(Radius.circular(10))),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.current.upgrade_premium, style: const TextStyle(fontSize: 25, color: Colors.white)),
                            Text(S.current.unlock_premium_tips, style: const TextStyle(fontSize: 15, color: Colors.white70))
                          ],
                        ),
                        const Spacer(flex: 1),
                        const Card(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.all(Radius.circular(10))),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Text(
                                'Pro',
                                style: TextStyle(fontSize: 20),
                              ),
                            ))
                      ],
                    )),
                onTap: () {
                  Navigation.navigator(context, const PremiumScreenPage());
                },
              ),
              const SizedBox(
                height: 20,
              ),
              titleWidget(S.current.settings),
              categoryWidget([
                itemWidget(Icons.flight_takeoff, S.current.proxy_host,
                    subtitle: domainList
                        .firstWhere((element) => element.hostname == apiHost,
                            orElse: () => Domain(hostname: 'hostname', area: 'area'))
                        .area,
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.checklist_rounded),
                      itemBuilder: (context) {
                        return domainPopupItems;
                      },
                      onSelected: (value) async {
                        LocalStorageService().apiHost = value;
                        setState(() {
                          apiHost = value;
                        });
                        initialDomains();
                      },
                    )),
                divider(),
                itemWidget(Icons.text_format, 'Markdown',
                    trailing: Switch(
                        value: isEnableMarkdown,
                        onChanged: (v) {
                          setState(() {
                            isEnableMarkdown = v;
                            LocalStorageService().renderMode = v ? 'markdown' : 'text';
                          });
                        })),
                divider(),
                itemWidget(Icons.language, S.current.language,
                    subtitle: parseLanguage(LocalStorageService().currentLanguageCode),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.checklist_rounded),
                      itemBuilder: (context) {
                        return languageMenuItems;
                      },
                      onSelected: (value) async {
                        setState(() {
                          S.delegate.load(Locale(value));
                          LocalStorageService().languageCode = value;
                          initialLanguages();
                          EventBus.getDefault().post(EventMessage<EventType>(EventType.CHANGE_LANGUAGE));
                        });
                      },
                    )),
              ]),
              // titleWidget('高级'),
              // categoryWidget([
              //   itemWidgetPremiumWidget('会员订阅', () {
              //     Navigation.navigator(context, const PremiumScreenPage());
              //   }),
              //   divider(),
              //   itemWidget(Icons.restore_outlined, '恢复购买', onPressed: () async {
              //     var isAvailable = await InAppPurchase.instance.isAvailable();
              //     if (!isAvailable) {
              //       return;
              //     }
              //     InAppPurchase.instance.restorePurchases();
              //   })
              // ]),
              titleWidget(S.current.more),
              categoryWidget([
                itemWidget(Icons.share_outlined, S.current.share_app, onPressed: () {
                  if (Platform.isIOS || Platform.isMacOS) {
                    Share.share(Urls.appStoreUrl);
                  } else {
                    Share.share(Urls.googlePlayUrl);
                  }
                }),
                divider(),
                itemWidget(Icons.star_rate_outlined, S.current.rate_app, onPressed: () async {
                  if (Platform.isIOS || Platform.isMacOS) {
                    InAppReview.instance.openStoreListing(appStoreId: '6455787500');
                  } else if (Platform.isAndroid) {
                    await launchUrl(Uri.parse(Urls.googlePlayUrl), mode: LaunchMode.inAppWebView);
                  }
                }),
                divider(),
                itemWidget(Icons.privacy_tip_outlined, S.current.terms_use, onPressed: () async {
                  await launchUrl(Uri.parse(Urls.termsUrl), mode: LaunchMode.inAppWebView);
                }),
                divider(),
                itemWidget(Icons.info_outline, S.current.privacy_policy, onPressed: () async {
                  await launchUrl(Uri.parse(Urls.privacyUrl), mode: LaunchMode.inAppWebView);
                }),
                divider(),
                itemWidget(Icons.feedback_outlined, S.current.feedback, onPressed: () async {
                  final url = 'mailto:waitinghc@gmail.com?body=xxxx&subject=xxxx';
                  await launchUrlString(url);
                  // final Uri params = Uri(
                  //   scheme: 'mailto',
                  //   path: 'waitinghc@gmail.com',
                  //   query: 'xxxxxxx'
                  //   // query: encodeQueryParameters(<String, String>{
                  //   //   'subject': 'Your subject goes here'
                  //   // }),
                  // );
                  // var url = params.toString();
                  // await launchUrl(params);
                })
              ]),
              // titleWidget('应用推荐'),
              // categoryWidget([
              //   itemWidget(
              //       Icons.recommend_outlined,
              //       imageIcon: const ImageIcon(
              //           AssetImage(
              //               "assets/ic_muyu.png"),
              //           size: 20,
              //           color: null),
              //       'ChatAI - Chatbot', onPressed: () async {
              //     if (Platform.isIOS) {
              //       await launchUrl(Uri.parse('https://apps.apple.com/us/app/id6450460445?l=en-us'), mode: LaunchMode.inAppWebView);
              //     } else {
              //       await launchUrl(Uri.parse(Urls.googlePlayUrl), mode: LaunchMode.inAppWebView);
              //     }
              //   }),
              //   divider(),
              //   itemWidget(Icons.recommend_outlined, '木鱼 - 念经神器、冥想、打坐、放松', onPressed: () async {
              //     if (Platform.isIOS) {
              //       await launchUrl(Uri.parse(Urls.googlePlayUrl), mode: LaunchMode.inAppWebView);
              //     } else {
              //       await launchUrl(Uri.parse(Urls.muyuGooglePlayUrl), mode: LaunchMode.inAppWebView);
              //     }
              //   }),
              //   itemWidget(Icons.recommend_outlined, '二维码&条形码制作&扫码', onPressed: () async {
              //     if (Platform.isIOS) {
              //       await launchUrl(Uri.parse(Urls.googlePlayUrl), mode: LaunchMode.inAppWebView);
              //     } else {
              //       await launchUrl(Uri.parse(Urls.qrCodeGooglePlayUrl), mode: LaunchMode.inAppWebView);
              //     }
              //   }),
              // ]),
              const SizedBox(height: 10),
              FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, packageInfo) {
                    return Center(
                      child: Text(
                        "v${packageInfo.data?.version}-${EnvironmentConfig.APP_CHANNEL}",
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    );
                  }),
              const SizedBox(height: 100)
            ],
          )))
    ]);
  }

  Widget titleWidget(String title) {
    return Container(
        margin: const EdgeInsets.only(left: 15, top: 20, bottom: 5),
        child: Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ));
  }

  Widget categoryWidget(List<Widget> widgets) {
    return Container(
      // decoration: BoxDecoration(
      //     color: ThemeColor.appBarBackgroundColor, borderRadius: const BorderRadiusDirectional.all(Radius.circular(10))),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: widgets,
      ),
    );
  }

  Widget divider() {
    return Divider(height: 0.1, indent: 30.0, color: Colors.white.withOpacity(.05));
  }

  Widget itemWidget(IconData icon, String title,
      {ImageIcon? imageIcon, String? subtitle, Widget? trailing, VoidCallback? onPressed}) {
    return InkWell(
      hoverColor: Colors.black45,
      radius: 10,
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              imageIcon ??
                  Icon(
                    icon,
                    size: 20,
                    color: Colors.white70,
                  ),
              const SizedBox(
                width: 10,
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 15, color: Colors.white70),
              ),
              const Spacer(),
              Row(children: [
                Text(
                  subtitle ?? "",
                  style: const TextStyle(fontSize: 13, color: Colors.white54),
                ),
                trailing ??
                    const Icon(
                      Icons.navigate_next,
                      color: Colors.white70,
                    )
              ])
            ],
          )),
      onTap: () {
        onPressed?.call();
      },
    );
  }

  Widget itemWidgetPremiumWidget(String value, VoidCallback? onPressed) {
    return GestureDetector(
      child: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Lottie.asset('assets/animation_ll82pe8f.json', repeat: true),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(value, style: const TextStyle(fontSize: 15, color: Colors.white70)
                  // TextStyle(
                  //     foreground: Paint()
                  //       ..shader = ui.Gradient.linear(const Offset(0, 20), const Offset(130, 20), <Color>[
                  //         const Color(0xFF2EC0FF),
                  //         const Color(0xFFEE56D9),
                  //       ])),
                  ),
              const Spacer(),
              const Text(
                "普通会员",
                style: TextStyle(fontSize: 13, color: Colors.white54),
              ),
              const Icon(
                Icons.navigate_next,
                color: Colors.white70,
              )
            ],
          )),
      onTap: () {
        onPressed?.call();
      },
    );
  }
}
