import 'dart:io';

import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/conversation.dart';
import '../util/platform_util.dart';

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final Conversation? currentConversation;
  final bool? hasAppBar;
  final List<Widget>? actionWidgets;

  const CommonAppBar(this.title, {super.key, this.currentConversation, this.hasAppBar, this.actionWidgets});

  @override
  State<StatefulWidget> createState() {
    return _CommonAppBar();
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class _CommonAppBar extends State<CommonAppBar> {
  @override
  Widget build(BuildContext context) {
    return widget.hasAppBar == true || Platform.isIOS || Platform.isAndroid
        ? appBar(context)
        : (PlatformUtil.isMobile && !PlatformUtil.isLandscape(context))
            ? const SizedBox()
            : appBar(context);
  }

  Widget appBar(BuildContext context) {
    return AppBar(
        title: Text(widget.title ?? S.current.appName, style: const TextStyle(overflow: TextOverflow.ellipsis)),
        automaticallyImplyLeading: PlatformUtil.isMobile,
        actions: widget.actionWidgets);
  }
}
