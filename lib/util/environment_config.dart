class EnvironmentConfig {
  static const APP_CHANNEL =
      String.fromEnvironment('APP_CHANNEL', defaultValue: 'official');
  static const OTHER_VAR = String.fromEnvironment('OTHER_VAR');
}
