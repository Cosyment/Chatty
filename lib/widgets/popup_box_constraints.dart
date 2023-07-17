import 'package:flutter/rendering.dart';

import '../util/platform_util.dart';

class PopupBoxConstraints extends BoxConstraints {

  static BoxConstraints custom({ double? width, double? height }) {
    return BoxConstraints(
      minWidth: width ?? (PlatformUtl.isMobile ? 300.0 : 450.0),
      maxWidth: width ?? (PlatformUtl.isMobile ? 300.0 : 450.0),
      minHeight: height ?? (PlatformUtl.isMobile ? 50.0 : 100.0),
      maxHeight: height ?? (PlatformUtl.isMobile ? 180.0 : 230.0),
    );
  }
}
