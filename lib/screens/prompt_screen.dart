import 'package:chatbotty/api/http_request.dart';
import 'package:chatbotty/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/prompt.dart';
import '../services/local_storage_service.dart';
import '../util/platform_util.dart';

class PromptScreen extends StatelessWidget {
  List<Prompt> promptList = [];

  PromptScreen({super.key});

  @override
  StatelessElement createElement() {
    fetchPromptList();
    return super.createElement();
  }

  void fetchPromptList() async {
    var prompts = await HttpRequest.request<Prompt>(
        Urls.queryPromptByCountryCode,
        params: {
          'countryCode': LocalStorageService().currentCountryCode.toString()
        },
        (p0) => Prompt.fromJson(p0));

    if (prompts != null && prompts is List && prompts.isNotEmpty) {
      for (var element in prompts) {
        promptList.add(
            Prompt(title: element.title, promptContent: element.promptContent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.settings),
            automaticallyImplyLeading: PlatformUtl.isMobile),
        body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: promptList.length,
            itemBuilder: (context, index) {
              return promptItem(promptList[index]);
            }));
  }
}

Widget promptItem(Prompt prompt) {
  return Text(prompt.title,style: TextStyle(color: Colors.amber));
}
