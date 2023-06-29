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

  /// `Chatbotty`
  String get appName {
    return Intl.message(
      'Chatbotty',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `閒聊`
  String get chat {
    return Intl.message(
      '閒聊',
      name: 'chat',
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

  /// `Add your secret API key`
  String get add_your_secret_api_key {
    return Intl.message(
      'Add your secret API key',
      name: 'add_your_secret_api_key',
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

  /// `API Host Optional`
  String get api_host_optional {
    return Intl.message(
      'API Host Optional',
      name: 'api_host_optional',
      desc: '',
      args: [],
    );
  }

  /// `Manage API keys`
  String get manage_api_keys {
    return Intl.message(
      'Manage API keys',
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

  /// `Create or choose a conversation to start`
  String get create_conversation_to_start {
    return Intl.message(
      'Create or choose a conversation to start',
      name: 'create_conversation_to_start',
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
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'zh'),
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
