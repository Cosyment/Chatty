class SecretKey {
  final int id;
  final String apiKey;

  SecretKey({required this.id, required this.apiKey});

  factory SecretKey.fromJson(Map<String, dynamic> json) {
    return SecretKey(
      id: json['id'],
      apiKey: json['apiKey']
    );
  }
}
