import 'dart:io';

import 'package:chatbotty/util/environment_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/local_storage_service.dart';
import '../util/string_util.dart';

class SettingsScreenPage extends StatefulWidget {
  const SettingsScreenPage({super.key});

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

  final _textFieldController = TextEditingController();

  Future openStringDialog(
          BuildContext context, String title, String hintText) =>
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: _textFieldController,
                decoration: InputDecoration(hintText: hintText),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () =>
                      Navigator.pop(context, _textFieldController.text),
                ),
                ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.ok),
                  onPressed: () =>
                      Navigator.pop(context, _textFieldController.text),
                ),
              ],
            );
          });

  String obscureApiKey(String apiKey) {
    if (apiKey.length < 7) {
      return AppLocalizations.of(context)!.invalid_api_key;
    }
    if (apiKey.substring(0, 3) != 'sk-') {
      return AppLocalizations.of(context)!.invalid_api_key;
    }
    return 'sk-...${LocalStorageService().apiKey.substring(LocalStorageService().apiKey.length - 4, LocalStorageService().apiKey.length)}';
  }

  String shortValue(String value) {
    if (!kIsWeb && Platform.isIOS && value != null && value.length >= 10) {
      return " ${value.substring(0, 15)}...";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(AppLocalizations.of(context)!.authentication),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.key),
                title: const Text(
                  'API Key',
                  softWrap: false,
                ),
                value: SizedBox(
                    child: Text(
                  LocalStorageService().apiKey == ''
                      ? AppLocalizations.of(context)!.add_your_secret_api_key
                      : obscureApiKey(LocalStorageService().apiKey),
                  overflow: TextOverflow.ellipsis,
                )),
                onPressed: (context) async {
                  _textFieldController.text = LocalStorageService().apiKey;
                  var result = await openStringDialog(context, 'API Key',
                          'Open AI API Key like sk-........') ??
                      '';
                  LocalStorageService().apiKey = result;
                  setState(() {
                    apiKey = result;
                  });
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.group),
                title: Text(AppLocalizations.of(context)!.organization,
                    softWrap: false),
                value: SizedBox(
                    child: Text(
                        LocalStorageService().organization == ''
                            ? 'None'
                            : shortValue(LocalStorageService().organization),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis)),
                onPressed: (context) async {
                  _textFieldController.text =
                      LocalStorageService().organization;
                  var result = await openStringDialog(
                          context,
                          AppLocalizations.of(context)!.organization,
                          'Organization ID like org-.......') ??
                      '';
                  LocalStorageService().organization = result;
                  setState(() {
                    organization = result;
                  });
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.flight_takeoff),
                title: Text(AppLocalizations.of(context)!.api_host,
                    softWrap: false),
                value: SizedBox(
                    child: Text(
                  shortValue(
                      'Access ${'${stripTrailingSlash(LocalStorageService().apiHost)}/v1/chat/completions'}'),
                )),
                onPressed: (context) async {
                  _textFieldController.text = LocalStorageService().apiHost;
                  var result = await openStringDialog(
                          context,
                          AppLocalizations.of(context)!.api_host_optional,
                          'URL like https://api.openai.com') ??
                      '';
                  LocalStorageService().apiHost = result;
                  setState(() {
                    apiHost = result;
                  });
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.open_in_new),
                title: Text(AppLocalizations.of(context)!.manage_api_keys,
                    softWrap: false),
                value: SizedBox(
                    child: Text(
                  shortValue('https://platform.openai.com/account/api-keys'),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                )),
                onPressed: (context) async {
                  await launchUrl(
                      Uri.parse('https://platform.openai.com/account/api-keys'),
                      mode: LaunchMode.externalApplication);
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
                      return const [
                        PopupMenuItem(
                          value: 'gpt-3.5-turbo',
                          child: Text('gpt-3.5-turbo'),
                        ),
                        PopupMenuItem(
                          value: 'gpt-4',
                          child: Text('gpt-4'),
                        ),
                        PopupMenuItem(
                          value: 'gpt-4-32k',
                          child: Text('gpt-4-32k'),
                        )
                      ];
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
                    shortValue('https://chat.cosyment.com/privacy.html'),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  )),
                  onPressed: (context) async {
                    await launchUrl(
                        Uri.parse('https://chat.cosyment.com/privacy.html'),
                        mode: LaunchMode.externalApplication);
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
              ])
        ],
      ),
    );
  }
}
