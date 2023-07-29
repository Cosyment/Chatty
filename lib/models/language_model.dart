class LanguageModel {
  final int id;
  final int type;
  final String modelName;

  LanguageModel({this.id = 0, this.type = -1, required this.modelName});

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(id: json['id'], type: json['type'], modelName: json['modelName']);
  }
}
