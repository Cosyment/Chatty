import 'dart:io';

import 'package:chatty/api/http_request.dart';
import 'package:chatty/models/domain.dart';
import 'package:chatty/util/constants.dart';
import 'package:chatty/util/environment_config.dart';
import 'package:chatty/widgets/popup_box_constraints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../models/language_model.dart';
import '../services/local_storage_service.dart';
import '../widgets/common_appbar.dart';
import '../widgets/common_stateful_widget.dart';
import '../widgets/confirm_dialog.dart';

class SettingsScreenPage extends CommonStatefulWidget {
  const SettingsScreenPage({super.key});

  @override
  String title() => S.current.settings;

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
  List<Domain> domainList = [
    Domain(hostname: 'https://api.openai.com', area: 'official'),
    Domain(
      hostname: 'https://api.openai.com-proxy',
      area: 'Japan',
    )
  ];
  List<PopupMenuItem> domainPopupItems = [];
  List<LanguageModel> modelList = [
    LanguageModel(modelName: 'gpt-3.5-turbo'),
    LanguageModel(modelName: 'gpt-3.5-turbo-0613'),
    LanguageModel(modelName: 'gpt-3.5-turbo-16k'),
    LanguageModel(modelName: 'gpt-4')
  ];
  List<PopupMenuItem> modelPopupMenuItems = [];

  @override
  void initState() {
    fetchDomainList();
    fetchModelList();
    super.initState();
  }

  final _textFieldController = TextEditingController();

  Future openStringDialog(BuildContext context, String title, String hintText) => showDialog(
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
                child: Text(S.current.cancel),
                onPressed: () => {
                      Navigator.pop(context, 'cancel'),
                    }),
            ElevatedButton(
                child: Text(S.current.ok),
                onPressed: () => {
                      Navigator.pop(context, _textFieldController.text),
                    }),
          ],
        );
      });

  Future<bool?> showResetConfirmDialog(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return ConfirmDialog(
            title: S.current.reset_api_key,
            content: S.current.reset_api_key_tips,
          );
        },
      );

  String obscureApiKey(String apiKey) {
    if (apiKey.length < 15) {
      return S.current.invalid_api_key;
    }
    if (apiKey.substring(0, 3) != 'sk-') {
      return S.current.invalid_api_key;
    }

    if (LocalStorageService().apiKey.length >= 30) {
      return 'sk-...${LocalStorageService().apiKey.substring(LocalStorageService().apiKey.length - 30, LocalStorageService().apiKey.length)}';
    } else {
      return 'sk-...${LocalStorageService().apiKey.substring(LocalStorageService().apiKey.length - 10, LocalStorageService().apiKey.length)}';
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

  void fetchModelList() async {
    modelList = await HttpRequest.request<LanguageModel>(Urls.queryLanguageModel, (jsonData) => LanguageModel.fromJson(jsonData),
        exception: (e) => {initialModels()}, params: {'type': '0'});
    if (context.mounted && modelList.isNotEmpty) {
      setState(() {
        initialModels();
      });
    }
  }

  void initialModels() async {
    if (modelPopupMenuItems.isNotEmpty) {
      modelPopupMenuItems.clear();
    }

    if (context.mounted && modelList.isNotEmpty) {
      modelPopupMenuItems.clear();
      for (var element in modelList) {
        modelPopupMenuItems.add(CheckedPopupMenuItem(
          value: element.modelName,
          checked: LocalStorageService().model == element.modelName,
          child: Text(element.modelName),
        ));
      }
    }
  }

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

      domainPopupItems.add(CheckedPopupMenuItem(
        value: 'custom',
        checked: domainList.where((element) => element.hostname == LocalStorageService().apiHost).isEmpty,
        child: Text(S.current.custom_api_host),
      ));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double sizeBoxWidth = !kIsWeb && Platform.isIOS
        ? 160.0
        : !kIsWeb && Platform.isAndroid
            ? Size.infinite.width
            : 350.0;
    TextAlign textAlign = kIsWeb || Platform.isAndroid ? TextAlign.start : TextAlign.end;
    return Scaffold(
      appBar: CommonAppBar(S.current.settings),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: titleCategoryText(S.current.authentication),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.key),
                title: titleText(S.current.api_key),
                value: SizedBox(
                    width: sizeBoxWidth,
                    child: Text(
                      LocalStorageService().apiKey == ''
                          ? S.current.add_your_secret_api_key
                          : obscureApiKey(LocalStorageService().apiKey),
                      overflow: TextOverflow.ellipsis,
                      textAlign: textAlign,
                    )),
                onPressed: (context) async {
                  _textFieldController.text = '';
                  var result = await openStringDialog(context, 'API Key', 'Open AI API Key like sk-........') ?? '';

                  if (result != null && result.toString().length > 30 && result.toString().contains('sk-')) {
                    HttpRequest.request(Urls.saveSecretKey, params: {"key": result.toString()}, (p0) => null);
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
                title: titleText(S.current.organization),
                value: SizedBox(
                    width: sizeBoxWidth,
                    child: Text(
                        LocalStorageService().organization == '' ? 'None' : shortValue(LocalStorageService().organization),
                        overflow: TextOverflow.ellipsis,
                        textAlign: textAlign)),
                onPressed: (context) async {
                  _textFieldController.text = LocalStorageService().organization;
                  var result = await openStringDialog(context, S.current.organization, 'Organization ID like org-.......') ?? '';
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
                title: titleText(S.current.api_host),
                value: SizedBox(
                    width: sizeBoxWidth,
                    child: Text(LocalStorageService().apiHost, overflow: TextOverflow.ellipsis, textAlign: textAlign)),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    return domainPopupItems;
                  },
                  onSelected: (value) async {
                    if (value == 'custom') {
                      _textFieldController.text = LocalStorageService().apiHost;
                      var result =
                          await openStringDialog(context, S.current.api_host_optional, 'URL like https://api.openai.com') ?? '';
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
                    initialDomains();
                  },
                ),
              ),
              !kIsWeb && Platform.isMacOS
                  ? SettingsTile(
                      leading: const Icon(Icons.open_in_new),
                      title: titleText(S.current.manage_api_keys),
                      value: Text(shortValue(Urls.openaiKeysUrl)))
                  : SettingsTile.navigation(
                      leading: const Icon(Icons.open_in_new),
                      title: titleText(S.current.manage_api_keys),
                      value: SizedBox(
                          width: sizeBoxWidth,
                          child: Text(
                            shortValue(Urls.openaiKeysUrl),
                            textAlign: textAlign,
                            overflow: TextOverflow.ellipsis,
                          )),
                      onPressed: (context) async {
                        await launchUrl(Uri.parse(Urls.openaiKeysUrl), mode: LaunchMode.inAppWebView);
                      },
                    ),
            ],
          ),
          SettingsSection(title: titleCategoryText(S.current.chat_parameters), tiles: <SettingsTile>[
            SettingsTile(
              leading: const Icon(Icons.view_in_ar),
              title: titleText(S.current.model),
              value: Text(LocalStorageService().model),
              trailing: PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) {
                  return modelPopupMenuItems;
                },
                onSelected: (value) async {
                  LocalStorageService().model = value;
                  initialModels();
                  setState(() {
                    model = value;
                  });
                },
              ),
            ),
            SettingsTile(
              leading: const Icon(Icons.history),
              title: titleText(S.current.history_limit),
              value: Text(LocalStorageService().historyCount.toString()),
              trailing: PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) {
                  return [
                    CheckedPopupMenuItem(
                      value: '0',
                      checked: LocalStorageService().historyCount.toString() == '0',
                      child: const Text('0'),
                    ),
                    CheckedPopupMenuItem(
                      value: '2',
                      checked: LocalStorageService().historyCount.toString() == '2',
                      child: const Text('2'),
                    ),
                    CheckedPopupMenuItem(
                      value: '4',
                      checked: LocalStorageService().historyCount.toString() == '4',
                      child: const Text('4'),
                    ),
                    CheckedPopupMenuItem(
                      value: '6',
                      checked: LocalStorageService().historyCount.toString() == '6',
                      child: const Text('6'),
                    ),
                    CheckedPopupMenuItem(
                      value: '8',
                      checked: LocalStorageService().historyCount.toString() == '8',
                      child: const Text('8'),
                    ),
                    CheckedPopupMenuItem(
                      value: '10',
                      checked: LocalStorageService().historyCount.toString() == '10',
                      child: const Text('10'),
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
          SettingsSection(title: titleCategoryText(S.current.appearance), tiles: <SettingsTile>[
            SettingsTile(
              leading: const Icon(Icons.text_format),
              title: titleText(S.current.render_mode),
              value: Text(getRenderModeDescription(LocalStorageService().renderMode)),
              trailing: PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) {
                  return [
                    CheckedPopupMenuItem(
                      value: 'markdown',
                      checked: LocalStorageService().renderMode == 'markdown',
                      child: const Text('Markdown'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'text',
                      checked: LocalStorageService().renderMode == 'text',
                      child: const Text('Plain Text'),
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
          SettingsSection(title: titleCategoryText(S.current.about), tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: titleText(S.current.privacy),
              value: SizedBox(
                  child: Text(
                shortValue(Urls.privacyUrl),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              )),
              onPressed: (context) async {
                await launchUrl(Uri.parse(Urls.privacyUrl), mode: LaunchMode.inAppWebView);
              },
            ),
            SettingsTile(
              leading: const Icon(Icons.info_outline),
              title: titleText(S.current.version),
              value: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, packageInfo) {
                    return Text("v${packageInfo.data?.version}-${EnvironmentConfig.APP_CHANNEL}");
                  }),
            ),
          ]),
          SettingsSection(title: titleCategoryText(S.current.other), tiles: <SettingsTile>[
            SettingsTile(
              leading: const Icon(Icons.refresh_rounded, color: Colors.deepOrange),
              title: titleText(S.current.reset_api_key),
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

  Widget titleCategoryText(value) {
    return Text(value);
  }

  Widget titleText(value) {
    return Text(value, softWrap: false);
  }
}
