class Domain {
  final int id;
  final String hostname;
  final int type;
  final String area;
  final int status;

  Domain({this.id = 0, required this.hostname, this.type = -1, required this.area, this.status = -1});

  // Domain({this.id = 0, required this.hostname, required this.area})

  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain(id: json['id'], hostname: json['hostname'], type: json['type'], area: json['area'], status: json['status']);
  }
}
