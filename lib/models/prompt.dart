class Prompt{
  final title;
  final promptContent;

  Prompt({required this.title,required this.promptContent});

  factory Prompt.fromJson(Map<String,dynamic> json){
    return Prompt(title: json['title'], promptContent: json['promptContent']);
  }
}