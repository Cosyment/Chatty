import 'package:flutter/material.dart';

import '../generated/l10n.dart';

abstract class CommonStatefulWidget extends StatefulWidget {
  const CommonStatefulWidget({super.key});

  String title() => S.current.appName;
}
