class LanguageModel {
  final int id;
  final int type;
  final String modelName;

  LanguageModel({required this.id,required this.type, required this.modelName});

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(id: json['id'],type: json['type'], modelName: json['modelName']);
  }
}
