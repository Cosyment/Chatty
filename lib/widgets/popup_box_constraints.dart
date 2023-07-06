import 'package:flutter/rendering.dart';

import '../util/platform_util.dart';

class PopupBoxConstraints extends BoxConstraints {

  static BoxConstraints custom({ double? width, double? height }) {
    return BoxConstraints(
      minWidth: width ?? (PlatformUtl.isMobile ? 300.0 : 500.0),
      maxWidth: width ?? (PlatformUtl.isMobile ? 300.0 : 500.0),
      minHeight: height ?? (PlatformUtl.isMobile ? 100.0 : 130.0),
      maxHeight: height ?? (PlatformUtl.isMobile ? 200.0 : 230.0),
    );
  }
}
