import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AndroidBackTop {
  //初始化通信管道-设置退出到手机桌面
  static const String CHANNEL = "android/back/desktop";

  //设置回退到手机桌面
  static Future<bool> backDeskTop() async {
    const platform = MethodChannel(CHANNEL);
    //通知安卓返回,到手机桌面
    try {
      final bool out = await platform.invokeMethod('backDesktop');
      if (out) debugPrint('返回到桌面');
    } on PlatformException {
      debugPrint("通信失败(设置回退到安卓手机桌面:设置失败)");
    }
    return Future.value(false);
  }
}
