import 'package:chatty/widgets/common_stateful_widget.dart';
import 'package:flutter/material.dart';

import '../widgets/common_appbar.dart';

class HomeScreenPage extends CommonStatefulWidget {
  const HomeScreenPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        appBar: CommonAppBar(
          'Home',
          hasAppBar: true,
        ),
        body: Text('Home'));
  }
}
