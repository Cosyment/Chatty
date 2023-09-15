import 'package:chatty/widgets/common_stateful_widget.dart';
import 'package:flutter/material.dart';

import '../widgets/common_appbar.dart';

class TranslateScreenPage extends CommonStatefulWidget {
  const TranslateScreenPage({super.key});

  @override
  State<StatefulWidget> createState() => _TranslateState();
}

class _TranslateState extends State<TranslateScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppBar(
          'Translate',
          hasAppBar: true,
        ),
        body: Text('TranslateScreen'));
  }
}
