import 'package:chatty/screens/premium_screen.dart';
import 'package:chatty/widgets/popup_box_constraints.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../generated/l10n.dart';
import '../util/navigation.dart';

class SubscribeDialog extends StatelessWidget {
  const SubscribeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: Text('你还不是会员哦，该功能仅对会员开放'),
      content: Container(
          constraints: PopupBoxConstraints.custom(height: 150.0),
          child: Column(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Lottie.asset('assets/animation_ll82pe8f.json'),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                S.current.your_are_not_membership,
                style: const TextStyle(fontSize: 15),
              )
            ],
          )),
      actions: [
        TextButton(
          child: Text(S.current.refuse),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text(S.current.subscribe),
          onPressed: () => {
            Navigator.pop(context),
            Navigation.navigator(context, const PremiumScreenPage())
          },
        ),
      ],
    );
  }
}
