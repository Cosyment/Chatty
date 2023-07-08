import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
// import 'package:device_inf';

class PlatformUtl {

  static bool get isMobile =>!kIsWeb&&(Platform.isAndroid || Platform.isIOS);

  static bool isPortrait(BuildContext context) {
    late Size size = MediaQuery.of(context).size;
    return size.width < size.height;
  }

  static Future<bool> get isiPad async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return false;
  }
}
