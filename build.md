# Build apk for channel command
```flutter build apk --dart-define=APP_CHANNEL=xxx-channel --dart-define=OTHER_VAR=Dart(optional) --target-platform android-arm,android-arm64,android-x64 --split-per-abi```

**小米**
```flutter build apk --dart-define=APP_CHANNEL=xiaomi --target-platform android-arm64 --split-per-abi```

**华为**
```flutter build apk --dart-define=APP_CHANNEL=huawei --target-platform android-arm64 --split-per-abi```

**亚马逊**
```flutter build apk --dart-define=APP_CHANNEL=amazon --target-platform android-arm64 --split-per-abi```

**三星**
```flutter build apk --dart-define=APP_CHANNEL=samsung --target-platform android-arm64 --split-per-abi```

**Google**
```flutter build appbundle --dart-define=APP_CHANNEL=google --target-platform android-arm64 --split-per-abi```
