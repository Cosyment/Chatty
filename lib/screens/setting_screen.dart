import 'dart:io';

import 'package:chatbotty/api/http_request.dart';
import 'package:chatbotty/models/domain.dart';
import 'package:chatbotty/screens/tablet_screen.dart';
import 'package:chatbotty/util/constants.dart';
import 'package:chatbotty/util/environment_config.dart';
import 'package:chatbotty/util/platform_util.dart';
import 'package:chatbotty/widgets/popup_box_constraints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/language_model.dart';
import '../services/local_storage_service.dart';
import '../widgets/confirm_dialog.dart';
import 'conversation_screen.dart';

class SettingsScreenPage extends StatefulWidget {
  const SettingsScreenPage({super.key});

  static Route<void> route(){
    return PageRouteBuilder(
        pageBuilder: (context, animation,
            secodaryAnmation) =>
        const TabletScreenPage(
            sidebar: ConversationScreen(
              selectedConversation: null,
            ),
            body: SettingsScreenPage()),
        transitionDuration: Duration.zero);
  }

  @override
  State<SettingsScreenPage> createState() => _SettingsScreenPageState();
}

class _SettingsScreenPageState extends State<SettingsScreenPage> {

  String apiKey = LocalStorageService().apiKey;
  String organization = LocalStorageService().organization;
  String apiHost = LocalStorageService().apiHost;
  String model = LocalStorageService().model;
  int historyCount = LocalStorageService().historyCount;
  String renderMode = LocalStorageService().renderMode;
  List<PopupMenuItem> domainPopupItems = [
    const PopupMenuItem(
      value: 'https://api.openai-proxy.com',
      child: Text('https://api.openai-proxy.com'),
    ),
    const PopupMenuItem(
      value: 'https://api.openai.com',
      child: Text('https://api.openai.com'),
    )
  ];
  List<PopupMenuItem> modelPopupMenuItems = [
    const PopupMenuItem(
      value: 'gpt-3.5-turbo',
      child: Text('gpt-3.5-turbo'),
    ),
    const PopupMenuItem(
      value: 'gpt-4',
      child: Text('gpt-4'),
    ),
    const PopupMenuItem(
      value: 'gpt-4-32k',
      child: Text('gpt-4-32k'),
    )
  ];

  @override
  void initState() {
    super.initState();
    initialModels();
    initialDomains();
  }

  final _textFieldController = TextEditingController();

  Future openStringDialog(BuildContext context, String title,
      String hintText) =>
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Container(
                  constraints: PopupBoxConstraints.custom(),
                  child: TextField(
                    controller: _textFieldController,
                    decoration: InputDecoration(hintText: hintText),
                  )),
              actions: <Widget>[
                TextButton(
                    child: Text(AppLocalizations.of(context)!.cancel),
                    onPressed: () => {
                          Navigator.pop(context, 'cancel'),
                        }),
                ElevatedButton(
                    child: Text(AppLocalizations.of(context)!.ok),
                    onPressed: () => {
                          Navigator.pop(context, _textFieldController.text),
                        }),
              ],
            );
          });

  Future<bool?> showResetConfirmDialog(BuildContext context) =>
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            title: AppLocalizations.of(context)!.reset_api_key,
            content: AppLocalizations.of(context)!.reset_api_key_tips,
          );
        },
      );

  String obscureApiKey(String apiKey) {
    if (apiKey.length < 15) {
      return AppLocalizations.of(context)!.invalid_api_key;
    }
    if (apiKey.substring(0, 3) != 'sk-') {
      return AppLocalizations.of(context)!.invalid_api_key;
    }

    if (LocalStorageService().apiKey.length >= 30) {
      return 'sk-...${LocalStorageService().apiKey.substring(LocalStorageService().apiKey.length - 30, LocalStorageService().apiKey.length)}';
    } else {
      return 'sk-...${LocalStorageService().apiKey.substring(
          LocalStorageService().apiKey.length - 10,
          LocalStorageService().apiKey.length)}';
    }
  }

  String shortValue(String value) {
    if (!kIsWeb && Platform.isIOS && value.length >= 20) {
      return " ${value.substring(0, 20)}...";
    }
    return value;
  }

  String getRenderModeDescription(String renderMode) {
    if (renderMode == 'markdown') {
      return 'Markdown';
    }
    if (renderMode == 'text') {
      return 'Plain Text';
    }
    return 'Unknown';
  }

  void initialModels() async {
    var models = await HttpRequest.request<LanguageModel>(
        Urls.queryLanguageModel, (jsonData) => LanguageModel.fromJson(jsonData),
        params: {'type': '0'});

    if (models != null && models is List && models.isNotEmpty) {
      modelPopupMenuItems.clear();
      for (var element in models) {
        modelPopupMenuItems.add(PopupMenuItem(
          value: element.modelName,
          child: Text(element.modelName),
        ));
      }
    }
  }

  void initialDomains() async {
    var domains = await HttpRequest.request<Domain>(
        Urls.queryDomain,
        params: {'type': '0'},
        (jsonData) => Domain.fromJson(jsonData));
    if (domains != null && domains is List && domains.isNotEmpty) {
      domainPopupItems.clear();
      for (var element in domains) {
        domainPopupItems.add(PopupMenuItem(
          value: element.hostname,
          child: Text(element.area),
        ));
      }
    }

    domainPopupItems.add(PopupMenuItem(
      value: 'custom',
      child: Text(AppLocalizations.of(context)!.custom_api_host),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double sizeBoxWidth = !kIsWeb&&Platform.isIOS
        ? 160.0
        : !kIsWeb&&Platform.isAndroid
            ? Size.infinite.width
            : 350.0;
    TextAlign textAlign = kIsWeb||Platform.isAndroid ? TextAlign.start : TextAlign.end;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings),automaticallyImplyLeading:PlatformUtl.isMobile),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(AppLocalizations.of(context)!.authentication),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.key),
                title: Text(
                  AppLocalizations.of(context)!
                      .api_key,
                  softWrap: false,
                ),
                value: SizedBox(
                    width: sizeBoxWidth,
                    child: Text(
                      LocalStorageService().apiKey == ''
                          ? AppLocalizations.of(context)!
                              .add_your_secret_api_key
                          : obscureApiKey(LocalStorageService().apiKey),
                      overflow: TextOverflow.ellipsis,
                      textAlign: textAlign,
                    )),
                onPressed: (context) async {
                  _textFieldController.text = '';
                  var result = await openStringDialog(context, 'API Key',
                          'Open AI API Key like sk-........') ??
                      '';

                  if (result != null &&
                      result.toString().length > 30 &&
                      result.toString().contains('sk-')) {
                    HttpRequest.request(
                        Urls.saveSecretKey,
                        params: {"key": result.toString()},
                        (p0) => null);
                    LocalStorageService().apiKey = result;
                    LocalStorageService().isCustomApiKey = true;
                    setState(() {
                      apiKey = result;
                    });
                  }
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.group),
                title: Text(AppLocalizations.of(context)!.organization,
                    softWrap: false),
                value: SizedBox(
                    width: sizeBoxWidth,
                    child: Text(
                        LocalStorageService().organization == ''
                            ? 'None'
                            : shortValue(LocalStorageService().organization),
                        overflow: TextOverflow.ellipsis,
                        textAlign: textAlign)),
                onPressed: (context) async {
                  _textFieldController.text =
                      LocalStorageService().organization;
                  var result = await openStringDialog(
                          context,
                          AppLocalizations.of(context)!.organization,
                          'Organization ID like org-.......') ??
                      '';
                  if (result != 'cancel') {
                    LocalStorageService().organization = result;
                    setState(() {
                      organization = result;
                    });
                  }
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.flight_takeoff),
                title: Text(AppLocalizations.of(context)!.api_host),
                value: SizedBox(
                    width: sizeBoxWidth,
                    child: Text(LocalStorageService().apiHost,
                        overflow: TextOverflow.ellipsis, textAlign: textAlign)),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    return domainPopupItems;
                  },
                  onSelected: (value) async {
                    if (value == 'custom') {
                      _textFieldController.text = LocalStorageService().apiHost;
                      var result = await openStringDialog(
                              context,
                              AppLocalizations.of(context)!.api_host_optional,
                              'URL like https://api.openai.com') ??
                          '';
                      if (result != 'cancel') {
                        LocalStorageService().apiHost = result;
                        setState(() {
                          apiHost = result;
                        });
                      }
                    } else {
                      LocalStorageService().apiHost = value;
                      setState(() {
                        apiHost = value;
                      });
                    }
                  },
                ),
              ),
              !kIsWeb&&Platform.isMacOS
                  ? SettingsTile(
                      leading: const Icon(Icons.open_in_new),
                      title:
                          Text(AppLocalizations.of(context)!.manage_api_keys),
                      value: Text(shortValue(Urls.openaiKeysUrl)))
                  : SettingsTile.navigation(
                      leading: const Icon(Icons.open_in_new),
                      title: Text(AppLocalizations.of(context)!.manage_api_keys,
                          softWrap: false),
                      value: SizedBox(
                          width: sizeBoxWidth,
                          child: Text(
                            shortValue(Urls.openaiKeysUrl),
                            textAlign: textAlign,
                            overflow: TextOverflow.ellipsis,
                          )),
                      onPressed: (context) async {
                        await launchUrl(Uri.parse(Urls.openaiKeysUrl),
                            mode: LaunchMode.inAppWebView);
                      },
                    ),
            ],
          ),
          SettingsSection(
              title: Text(AppLocalizations.of(context)!.chat_parameters),
              tiles: <SettingsTile>[
                SettingsTile(
                  leading: const Icon(Icons.view_in_ar),
                  title: Text(AppLocalizations.of(context)!.model),
                  value: Text(LocalStorageService().model),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) {
                      return modelPopupMenuItems;
                    },
                    onSelected: (value) async {
                      LocalStorageService().model = value;
                      setState(() {
                        model = value;
                      });
                    },
                  ),
                ),
                SettingsTile(
                  leading: const Icon(Icons.history),
                  title: Text(AppLocalizations.of(context)!.history_limit),
                  value: Text(LocalStorageService().historyCount.toString()),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(
                          value: '0',
                          child: Text('0'),
                        ),
                        PopupMenuItem(
                          value: '2',
                          child: Text('2'),
                        ),
                        PopupMenuItem(
                          value: '4',
                          child: Text('4'),
                        ),
                        PopupMenuItem(
                          value: '6',
                          child: Text('6'),
                        ),
                        PopupMenuItem(
                          value: '8',
                          child: Text('8'),
                        ),
                        PopupMenuItem(
                          value: '10',
                          child: Text('10'),
                        )
                      ];
                    },
                    onSelected: (value) async {
                      int intValue = int.parse(value);
                      LocalStorageService().historyCount = intValue;
                      setState(() {
                        historyCount = intValue;
                      });
                    },
                  ),
                ),
              ]),
          SettingsSection(
              title: Text(AppLocalizations.of(context)!.appearance),
              tiles: <SettingsTile>[
                SettingsTile(
                  leading: const Icon(Icons.text_format),
                  title: Text(AppLocalizations.of(context)!.render_mode),
                  value: Text(getRenderModeDescription(
                      LocalStorageService().renderMode)),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(
                          value: 'markdown',
                          child: Text('Markdown'),
                        ),
                        PopupMenuItem(
                          value: 'text',
                          child: Text('Plain Text'),
                        )
                      ];
                    },
                    onSelected: (value) async {
                      LocalStorageService().renderMode = value;
                      setState(() {
                        renderMode = value;
                      });
                    },
                  ),
                ),
              ]),
          SettingsSection(
              title: Text(AppLocalizations.of(context)!.about),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(AppLocalizations.of(context)!.privacy,
                      softWrap: false),
                  value: SizedBox(
                      child: Text(
                    shortValue(Urls.privacyUrl),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  )),
                  onPressed: (context) async {
                    await launchUrl(Uri.parse(Urls.privacyUrl),
                        mode: LaunchMode.inAppWebView);
                  },
                ),
                SettingsTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(AppLocalizations.of(context)!.version,
                      softWrap: false),
                  value: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, packageInfo) {
                        return Text(
                            "v${packageInfo.data?.version}-${EnvironmentConfig.APP_CHANNEL}");
                      }),
                ),
              ]),
          SettingsSection(
              title: Text(AppLocalizations.of(context)!.other),
              tiles: <SettingsTile>[
                SettingsTile(
                  leading: const Icon(Icons.refresh_rounded,color:Colors.deepOrange),
                  title: Text(AppLocalizations.of(context)!.reset_api_key,
                      softWrap: false),
                  onPressed: (context) async {
                    var result = await showResetConfirmDialog(context);
                    if (result == true) {
                      setState(() {
                        LocalStorageService().apiKey = '';
                        LocalStorageService().isCustomApiKey = false;
                      });
                    }
                  },
                ),
              ])
        ],
      ),
    );
  }
}
