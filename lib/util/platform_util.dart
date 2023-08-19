import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PlatformUtil {
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static bool isLandscape(BuildContext context) {
    late Size size = MediaQuery.of(context).size;
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static Future<bool> get isPad async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    debugPrint('device identifier ${iosInfo.identifierForVendor}');
    return iosInfo.utsname.machine.toLowerCase().contains("ipad");
  }
}
