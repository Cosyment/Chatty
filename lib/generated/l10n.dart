// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Chatty`
  String get appName {
    return Intl.message(
      'Chatty',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message(
      'Chat',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `Discover`
  String get discover {
    return Intl.message(
      'Discover',
      name: 'discover',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get more {
    return Intl.message(
      'More',
      name: 'more',
      desc: '',
      args: [],
    );
  }

  /// `Conversations`
  String get conversations {
    return Intl.message(
      'Conversations',
      name: 'conversations',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Clear conversation`
  String get clear_conversation {
    return Intl.message(
      'Clear conversation',
      name: 'clear_conversation',
      desc: '',
      args: [],
    );
  }

  /// `Would you like to clear conversation history?`
  String get clear_conversation_tips {
    return Intl.message(
      'Would you like to clear conversation history?',
      name: 'clear_conversation_tips',
      desc: '',
      args: [],
    );
  }

  /// `Resend`
  String get resend {
    return Intl.message(
      'Resend',
      name: 'resend',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Send a message...`
  String get send_a_message {
    return Intl.message(
      'Send a message...',
      name: 'send_a_message',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Invalid API Key`
  String get invalid_api_key {
    return Intl.message(
      'Invalid API Key',
      name: 'invalid_api_key',
      desc: '',
      args: [],
    );
  }

  /// `Authentication`
  String get authentication {
    return Intl.message(
      'Authentication',
      name: 'authentication',
      desc: '',
      args: [],
    );
  }

  /// `API Key`
  String get api_key {
    return Intl.message(
      'API Key',
      name: 'api_key',
      desc: '',
      args: [],
    );
  }

  /// `Add your api key`
  String get add_your_secret_api_key {
    return Intl.message(
      'Add your api key',
      name: 'add_your_secret_api_key',
      desc: '',
      args: [],
    );
  }

  /// `Please add your api key first`
  String get please_add_your_api_key {
    return Intl.message(
      'Please add your api key first',
      name: 'please_add_your_api_key',
      desc: '',
      args: [],
    );
  }

  /// `Organization`
  String get organization {
    return Intl.message(
      'Organization',
      name: 'organization',
      desc: '',
      args: [],
    );
  }

  /// `API Host`
  String get api_host {
    return Intl.message(
      'API Host',
      name: 'api_host',
      desc: '',
      args: [],
    );
  }

  /// `Customization API Host`
  String get custom_api_host {
    return Intl.message(
      'Customization API Host',
      name: 'custom_api_host',
      desc: '',
      args: [],
    );
  }

  /// `API Host Optional`
  String get api_host_optional {
    return Intl.message(
      'API Host Optional',
      name: 'api_host_optional',
      desc: '',
      args: [],
    );
  }

  /// `Find Keys`
  String get manage_api_keys {
    return Intl.message(
      'Find Keys',
      name: 'manage_api_keys',
      desc: '',
      args: [],
    );
  }

  /// `Chat Parameters`
  String get chat_parameters {
    return Intl.message(
      'Chat Parameters',
      name: 'chat_parameters',
      desc: '',
      args: [],
    );
  }

  /// `Model`
  String get model {
    return Intl.message(
      'Model',
      name: 'model',
      desc: '',
      args: [],
    );
  }

  /// `History Limit`
  String get history_limit {
    return Intl.message(
      'History Limit',
      name: 'history_limit',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: '',
      args: [],
    );
  }

  /// `Render Mode`
  String get render_mode {
    return Intl.message(
      'Render Mode',
      name: 'render_mode',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get privacy {
    return Intl.message(
      'Privacy',
      name: 'privacy',
      desc: '',
      args: [],
    );
  }

  /// `Title should not be empty`
  String get title_should_not_be_empty {
    return Intl.message(
      'Title should not be empty',
      name: 'title_should_not_be_empty',
      desc: '',
      args: [],
    );
  }

  /// `Enter a conversation title`
  String get enter_a_conversation_title {
    return Intl.message(
      'Enter a conversation title',
      name: 'enter_a_conversation_title',
      desc: '',
      args: [],
    );
  }

  /// `Message to help set the behavior of the`
  String get message_to_help_set_the_behavior_of_the {
    return Intl.message(
      'Message to help set the behavior of the',
      name: 'message_to_help_set_the_behavior_of_the',
      desc: '',
      args: [],
    );
  }

  /// `Edit conversation`
  String get edit_conversation {
    return Intl.message(
      'Edit conversation',
      name: 'edit_conversation',
      desc: '',
      args: [],
    );
  }

  /// `New conversation`
  String get new_conversation {
    return Intl.message(
      'New conversation',
      name: 'new_conversation',
      desc: '',
      args: [],
    );
  }

  /// `Delete conversation`
  String get delete_conversation {
    return Intl.message(
      'Delete conversation',
      name: 'delete_conversation',
      desc: '',
      args: [],
    );
  }

  /// `Would you like to delete the conversation?`
  String get delete_conversation_tips {
    return Intl.message(
      'Would you like to delete the conversation?',
      name: 'delete_conversation_tips',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Create or select a conversation`
  String get create_conversation_to_start {
    return Intl.message(
      'Create or select a conversation',
      name: 'create_conversation_to_start',
      desc: '',
      args: [],
    );
  }

  /// `tips: Entering '/' can trigger more surprises`
  String get create_conversation_tip {
    return Intl.message(
      'tips: Entering \'/\' can trigger more surprises',
      name: 'create_conversation_tip',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get other {
    return Intl.message(
      'Other',
      name: 'other',
      desc: '',
      args: [],
    );
  }

  /// `Reset API Key`
  String get reset_api_key {
    return Intl.message(
      'Reset API Key',
      name: 'reset_api_key',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reset the api key? After the reset, you need to add a new api key or restart the app`
  String get reset_api_key_tips {
    return Intl.message(
      'Are you sure you want to reset the api key? After the reset, you need to add a new api key or restart the app',
      name: 'reset_api_key_tips',
      desc: '',
      args: [],
    );
  }

  /// `Prompts`
  String get prompt {
    return Intl.message(
      'Prompts',
      name: 'prompt',
      desc: '',
      args: [],
    );
  }

  /// `Tips`
  String get reminder {
    return Intl.message(
      'Tips',
      name: 'reminder',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to clear all conversations？`
  String get clean_conversation_tips {
    return Intl.message(
      'Are you sure to clear all conversations？',
      name: 'clean_conversation_tips',
      desc: '',
      args: [],
    );
  }

  /// `Chat times has reached the limit today. review the ad to unlock more times`
  String get conversation_chat_reached_limit {
    return Intl.message(
      'Chat times has reached the limit today. review the ad to unlock more times',
      name: 'conversation_chat_reached_limit',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get language_code {
    return Intl.message(
      'English',
      name: 'language_code',
      desc: '',
      args: [],
    );
  }

  /// `Ad load failure,Please try again!`
  String get ad_load_failure {
    return Intl.message(
      'Ad load failure,Please try again!',
      name: 'ad_load_failure',
      desc: '',
      args: [],
    );
  }

  /// `Premium`
  String get premium {
    return Intl.message(
      'Premium',
      name: 'premium',
      desc: '',
      args: [],
    );
  }

  /// `Premium Features`
  String get premium_plus_explain {
    return Intl.message(
      'Premium Features',
      name: 'premium_plus_explain',
      desc: '',
      args: [],
    );
  }

  /// `Send Unlimited`
  String get premium_features1 {
    return Intl.message(
      'Send Unlimited',
      name: 'premium_features1',
      desc: '',
      args: [],
    );
  }

  /// `Support GPT4`
  String get premium_features2 {
    return Intl.message(
      'Support GPT4',
      name: 'premium_features2',
      desc: '',
      args: [],
    );
  }

  /// `Support Markdown Render`
  String get premium_features3 {
    return Intl.message(
      'Support Markdown Render',
      name: 'premium_features3',
      desc: '',
      args: [],
    );
  }

  /// `Higher word limit`
  String get premium_features4 {
    return Intl.message(
      'Higher word limit',
      name: 'premium_features4',
      desc: '',
      args: [],
    );
  }

  /// `Custom API Host`
  String get premium_features5 {
    return Intl.message(
      'Custom API Host',
      name: 'premium_features5',
      desc: '',
      args: [],
    );
  }

  /// `No Ad`
  String get premium_features6 {
    return Intl.message(
      'No Ad',
      name: 'premium_features6',
      desc: '',
      args: [],
    );
  }

  /// `Subscribe`
  String get subscribe {
    return Intl.message(
      'Subscribe',
      name: 'subscribe',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Failure`
  String get purchase_failure {
    return Intl.message(
      'Purchase Failure',
      name: 'purchase_failure',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations Subscribe Success!`
  String get purchase_success {
    return Intl.message(
      'Congratulations Subscribe Success!',
      name: 'purchase_success',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Cancel`
  String get purchase_cancel {
    return Intl.message(
      'Purchase Cancel',
      name: 'purchase_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Unknown Error`
  String get purchase_error {
    return Intl.message(
      'Purchase Unknown Error',
      name: 'purchase_error',
      desc: '',
      args: [],
    );
  }

  /// `Terms Use`
  String get terms_use {
    return Intl.message(
      'Terms Use',
      name: 'terms_use',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message(
      'Restore',
      name: 'restore',
      desc: '',
      args: [],
    );
  }

  /// `Current`
  String get current_level {
    return Intl.message(
      'Current',
      name: 'current_level',
      desc: '',
      args: [],
    );
  }

  /// `You have not subscribed to the membership service yet`
  String get your_are_not_membership {
    return Intl.message(
      'You have not subscribed to the membership service yet',
      name: 'your_are_not_membership',
      desc: '',
      args: [],
    );
  }

  /// `Not now`
  String get refuse {
    return Intl.message(
      'Not now',
      name: 'refuse',
      desc: '',
      args: [],
    );
  }

  /// `Nothing to Restore`
  String get nothing_to_restore {
    return Intl.message(
      'Nothing to Restore',
      name: 'nothing_to_restore',
      desc: '',
      args: [],
    );
  }

  /// `Weekly`
  String get premium_weekly {
    return Intl.message(
      'Weekly',
      name: 'premium_weekly',
      desc: '',
      args: [],
    );
  }

  /// `Monthly`
  String get premium_monthly {
    return Intl.message(
      'Monthly',
      name: 'premium_monthly',
      desc: '',
      args: [],
    );
  }

  /// `Quarterly`
  String get premium_quarterly {
    return Intl.message(
      'Quarterly',
      name: 'premium_quarterly',
      desc: '',
      args: [],
    );
  }

  /// `Yearly`
  String get premium_yearly {
    return Intl.message(
      'Yearly',
      name: 'premium_yearly',
      desc: '',
      args: [],
    );
  }

  /// `Ask me anything...`
  String get ask_anything {
    return Intl.message(
      'Ask me anything...',
      name: 'ask_anything',
      desc: '',
      args: [],
    );
  }

  /// `You still have {times} free messages today`
  String today_conversation_limit_tips(int times) {
    return Intl.message(
      'You still have $times free messages today',
      name: 'today_conversation_limit_tips',
      desc: 'A message with a single parameter',
      args: [times],
    );
  }

  /// `Upgrade Premium`
  String get upgrade_premium {
    return Intl.message(
      'Upgrade Premium',
      name: 'upgrade_premium',
      desc: '',
      args: [],
    );
  }

  /// `Unlimited sessions & No Ad`
  String get unlock_premium_tips {
    return Intl.message(
      'Unlimited sessions & No Ad',
      name: 'unlock_premium_tips',
      desc: '',
      args: [],
    );
  }

  /// `Proxy Host`
  String get proxy_host {
    return Intl.message(
      'Proxy Host',
      name: 'proxy_host',
      desc: '',
      args: [],
    );
  }

  /// `Share App`
  String get share_app {
    return Intl.message(
      'Share App',
      name: 'share_app',
      desc: '',
      args: [],
    );
  }

  /// `Rate App`
  String get rate_app {
    return Intl.message(
      'Rate App',
      name: 'rate_app',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedback {
    return Intl.message(
      'Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
