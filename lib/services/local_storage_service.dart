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

  static const storeConversationList = 'store_conversations';
  static const storeConversationPrefix = 'store_conversation_';
  static const storeCurrentConversation = 'store_current_conversation';

  // preferences

  String get apiKey =>
      _prefs.getString(prefApiKey) ??
      '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';

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
      return 'https://api.openai.com';
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

  String get conversationListJson =>
      _prefs.getString(storeConversationList) ?? '[]';

  set conversationListJson(String value) {
    (() async {
      await _prefs.setString(storeConversationList, value);
    })();
  }

  String getConversationJsonById(String id) =>
      _prefs.getString(storeConversationPrefix + id) ?? '';

  Future setConversationJsonById(String id, String value) async {
    await _prefs.setString(storeConversationPrefix + id, value);
  }

  Future removeConversationJsonById(String id) async {
    await _prefs.remove(storeConversationPrefix + id);
  }

  String get currentConversationId =>
      _prefs.getString(storeCurrentConversation) ?? '';

  set currentConversationId(String id) =>
      _prefs.setString(storeCurrentConversation, id);
}
