import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() => _instance;

  LocalStorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const prefApiKey = 'pref_apikey';
  static const prefOrganization = 'pref_organization';
  static const prefApiHost = 'pref_apiHost';
  static const prefModel = 'pref_model';
  static const prefHistoryCount = 'pref_historyCount';
  static const prefRenderMode = 'pref_renderMode';
  static const prefCustomApiKey = 'pref_customApiKey';
  static const prefCountry = 'pref_country';
  static const prefConversationLimit = 'pref_conversation_limit';
  static const prefAppLaunchTime = 'pref_app_launch_time';
  static const prefLanguageCode = 'pref_language_code';
  static const prefPad = 'pref_pad';
  static const prefMembershipProductId = 'pref_membership_productId';

  static const storeConversationList = 'store_conversations';
  static const storeConversationPrefix = 'store_conversation_';
  static const storeCurrentConversation = 'store_current_conversation';
  static const storePromptList = 'store_prompts';

  String? get appLaunchTime => _prefs.getString(prefAppLaunchTime);

  set updateAppLaunchTime(DateTime time) {
    _prefs.setString(prefAppLaunchTime, time.toString());
  }

  String get apiKey => _prefs.getString(prefApiKey) ?? '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';

  set apiKey(String value) {
    (() async {
      await _prefs.setString(prefApiKey, value);
    })();
  }

  String get organization => _prefs.getString(prefOrganization) ?? '';

  set organization(String value) {
    (() async {
      await _prefs.setString(prefOrganization, value);
    })();
  }

  String get apiHost {
    var result = _prefs.getString(prefApiHost);
    if ((result == null) || (result.isEmpty)) {
      // return 'https://api.openai.com';
      return 'https://api.openai-proxy.com';
    }
    return result;
  }

  set apiHost(String value) {
    (() async {
      await _prefs.setString(prefApiHost, value);
    })();
  }

  String get model => _prefs.getString(prefModel) ?? ChatRequest.defaultModel;

  set model(String value) {
    (() async {
      await _prefs.setString(prefModel, value);
    })();
  }

  int get historyCount => _prefs.getInt(prefHistoryCount) ?? 4;

  set historyCount(int value) {
    (() async {
      await _prefs.setInt(prefHistoryCount, value);
    })();
  }

  String get renderMode => _prefs.getString(prefRenderMode) ?? 'markdown';

  set renderMode(String value) {
    (() async {
      await _prefs.setString(prefRenderMode, value);
    })();
  }

  // storage

  String get conversationListJson => _prefs.getString(storeConversationList) ?? '[]';

  set conversationListJson(String value) {
    (() async {
      await _prefs.setString(storeConversationList, value);
    })();
  }

  String getConversationJsonById(String id) => _prefs.getString(storeConversationPrefix + id) ?? '';

  Future setConversationJsonById(String id, String value) async {
    await _prefs.setString(storeConversationPrefix + id, value);
  }

  Future removeConversationJsonById(String id) async {
    await _prefs.remove(storeConversationPrefix + id);
  }

  Future removeConversationJsonAll() async {
    await _prefs.remove(storeConversationPrefix);
  }

  String get currentConversationId => _prefs.getString(storeCurrentConversation) ?? '';

  set currentConversationId(String id) => _prefs.setString(storeCurrentConversation, id);

  bool get isChina =>
      _prefs.getString(prefCountry)?.toLowerCase() == 'cn' ||
      _prefs.getString(prefCountry)?.toLowerCase() == 'hk' ||
      _prefs.getString(prefCountry)?.toLowerCase() == 'tw';

  set currentCountryCode(String country) => _prefs.setString(prefCountry, country);

  String get currentCountryCode => _prefs.getString(prefCountry) ?? 'us';

  bool get isCustomApiKey => _prefs.getBool(prefCustomApiKey) ?? false;

  set isCustomApiKey(bool value) => _prefs.setBool(prefCustomApiKey, value);

  String get promptListJson => _prefs.getString(storePromptList) ?? '';

  set promptListJson(String value) {
    (() async {
      await _prefs.setString(storePromptList, value);
    })();
  }

  set conversationLimit(int count) => _prefs.setInt(prefConversationLimit, count);

  int get conversationLimit => _prefs.getInt(prefConversationLimit) ?? 0;

  set languageCode(String value) => _prefs.setString(prefLanguageCode, value);

  String? get currentLanguageCode => _prefs.getString(prefLanguageCode);

  set isPad(bool value) => _prefs.setBool(prefPad, value);

  bool get isPad => _prefs.getBool(prefPad) ?? false;

  set currentMembershipProductId(String productId) => _prefs.setString(prefMembershipProductId, productId);
  String getCurrentMembershipProductId() =>_prefs.getString(prefMembershipProductId)??'';
}
