import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:chatty/bloc/blocs.dart';
import 'package:chatty/event/event_bus.dart';
import 'package:chatty/screens/screens.dart';
import 'package:chatty/services/local_storage_service.dart';
import 'package:chatty/widgets/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../event/event_message.dart';
import '../generated/l10n.dart';
import '../services/chat_service.dart';
import '../util/platform_util.dart';
import '../widgets/common_stateful_widget.dart';

class TabletScreenPage extends StatefulWidget {
  final Widget sidebar;
  final Widget body;
  final TabletMainView mainView;

  const TabletScreenPage({super.key, required this.sidebar, required this.body, this.mainView = TabletMainView.body});

  @override
  State<StatefulWidget> createState() => _TableScreenPage();
}

class _TableScreenPage extends State<TabletScreenPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = NotchBottomBarController(index: 0);
  final _pageController = PageController(initialPage: 0);
  final List<Widget> bottomBarPages = [
    const HomeScreenPage(),
    // const TranslateScreenPage(),
    // const DrawScreenPage(),
    const PromptScreenPage(),
    const MoreScreenPage()
  ];

  @override
  void initState() {
    EventBus.getDefault().register<EventMessage<EventType>>(this, (event) {
      if (event.data == EventType.CLOSE_DRAWER) {
        scaffoldKey.currentState?.closeDrawer();
      } else if (event.data == EventType.CHANGE_LANGUAGE) {
        setState(() {});
      }
    });

    EventBus.getDefault().register<EventMessage<CommonStatefulWidget>>(this, (event) {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    // _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var chatService = context.read<ChatService>();
    var conversation = chatService.getConversationById(LocalStorageService().currentConversationId);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!PlatformUtil.isMobile || PlatformUtil.isLandscape(context)) {
          return Row(
            children: [
              SizedBox(
                width: 250,
                child: widget.sidebar,
              ),
              const VerticalDivider(thickness: .3, width: 1),
              Expanded(
                flex: 1,
                child: widget.body,
              )
            ],
          );
        } else {
          // return mainView == TabletMainView.body ? body : sidebar;
          String title = S.current.appName;
          if (widget.body is CommonStatefulWidget) {
            title = (widget.body as CommonStatefulWidget).title();
            conversation = null;
          } else if (widget.body is BlocProvider<ChatBloc>) {
            title = conversation?.title ?? title;
          }

          return
              //手机端增加appbar
              Scaffold(
            key: scaffoldKey,
            extendBody: true,
            //New added
            body: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(bottomBarPages.length, (index) => bottomBarPages[index])),

            bottomNavigationBar: AnimatedNotchBottomBar(
              notchBottomBarController: _controller,
              color: ThemeColor.primaryColor.withOpacity(.7),
              showLabel: true,
              showShadow: false,
              notchColor: ThemeColor.appBarBackgroundColor,
              removeMargins: false,
              bottomBarWidth: 450,
              durationInMilliSeconds: 150,
              bottomBarItems: const [
                BottomBarItem(inActiveItem: Icon(Icons.home_outlined), activeItem: Icon(Icons.home), itemLabel: '首页'),
                BottomBarItem(inActiveItem: Icon(Icons.explore_outlined), activeItem: Icon(Icons.explore), itemLabel: '发现'),
                // BottomBarItem(inActiveItem: Icon(Icons.abc_outlined), activeItem: Icon(Icons.abc), itemLabel: '翻译'),
                // BottomBarItem(inActiveItem: Icon(Icons.draw_outlined), activeItem: Icon(Icons.draw), itemLabel: '绘图'),
                BottomBarItem(inActiveItem: Icon(Icons.menu_outlined), activeItem: Icon(Icons.menu_rounded), itemLabel: '更多')
              ],
              onTap: (int value) {
                _pageController.animateToPage(value, duration: const Duration(milliseconds: 100), curve: Curves.easeOutQuad);
              },
            ),
          );
        }
      },
    );
  }
}

enum TabletMainView { sidebar, body }
