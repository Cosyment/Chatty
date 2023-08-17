class Constants {
  static const int DAILY_CONVERSATION_LIMIT = 5; //每日免费会话次数
  static const int REWARD_CONVERSATION_COUNT = 5; //广告奖励次数
  static int CURREN_WATCH_AD_COUNT = 0; //当前看广告次数
}

class Urls {
  static const String hostname = 'openai.api.firefix.cn';

  static const queryDomain = '/domain/queryAll';
  static const queryLanguageModel = '/model/query';
  static const querySecretKey = '/apikey/query';
  static const queryPromptAll = '/prompt/queryAll';
  static const queryPromptByType = '/prompt/queryByType';
  static const queryPromptByCountryCode = '/prompt/queryByCountryCode';
  static const queryPromptByLanguageCode = '/prompt/queryByLanguage';
  static const saveSecretKey = '/apikey/save';
  static const queryCountry = 'http://ip-api.com/json';

  static const openaiKeysUrl = 'https://platform.openai.com/account/api-keys';
  static const privacyUrl = 'https://chat.cosyment.com/privacy.html';
  static const termsUrl = 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula';
}
