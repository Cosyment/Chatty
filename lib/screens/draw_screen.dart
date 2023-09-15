import 'package:chatty/widgets/common_stateful_widget.dart';
import 'package:flutter/material.dart';

import '../widgets/common_appbar.dart';

class DrawScreenPage extends CommonStatefulWidget {
  const DrawScreenPage({super.key});

  @override
  State<StatefulWidget> createState() => _DrawState();
}

class _DrawState extends State<DrawScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar(
          'Draw',
          hasAppBar: true,
        ),
        body: Text('TranslateScreen'));
  }
}
