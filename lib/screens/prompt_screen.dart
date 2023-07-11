import 'package:chatbotty/api/http_request.dart';
import 'package:chatbotty/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/prompt.dart';
import '../services/local_storage_service.dart';
import '../util/platform_util.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PromptState();
  }
}

class _PromptState extends State<PromptScreen> {
  List<Prompt> promptList = [];

  @override
  void initState() {
    fetchPromptList();
    super.initState();
  }

  void fetchPromptList() async {
    var prompts = await HttpRequest.request<Prompt>(
        Urls.queryPromptByCountryCode,
        params: {
          'countryCode': LocalStorageService().currentCountryCode.toString()
        },
        (p0) => Prompt.fromJson(p0));

    if (prompts != null && prompts is List && prompts.isNotEmpty) {
      setState(() {
        for (var element in prompts) {
          promptList.add(Prompt(
              title: element.title, promptContent: element.promptContent));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Prompt'),
            automaticallyImplyLeading: PlatformUtl.isMobile),
        body: MasonryGridView.count(
          crossAxisCount: 3,
          //几列
          mainAxisSpacing: 5,
          // 间距
          crossAxisSpacing: 5,
          // 纵向间距？
          itemCount: promptList.length,
          //元素个数
          itemBuilder: (context, index) {
            return promptItem(promptList[index]);
          },
        )

        // GridView.builder(
        //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 3,
        //       mainAxisSpacing: 10,
        //       crossAxisSpacing: 10,
        //       childAspectRatio: 0.7,
        //     ),
        //     itemCount: promptList.length,
        //     itemBuilder: (context, index) {
        //       return promptItem(promptList[index]);
        //     }));
        );
  }
}

Widget promptItem(Prompt prompt) {
  return Column(
    children: [
      Container(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
          padding: EdgeInsets.all(5),
          child:
              Text(prompt.title, style: const TextStyle(color: Colors.amber))),
      Container(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
          padding: EdgeInsets.all(5),
          child: Text(prompt.promptContent,
              maxLines: 5,
              style: const TextStyle(color: Colors.amber)))
    ],
  );
}
