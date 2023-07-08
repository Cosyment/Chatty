class Domain {
  final int id;
  final String hostname;
  final int type;
  final String area;
  final int status;

  Domain(
      {required this.id, required this.hostname, required this.type,required this.area, required this.status});

  factory Domain.fromJson(Map<String, dynamic> json){
    return Domain(id: json['id'],
        hostname: json['hostname'],
        type: json['type'],
        area: json['area'],
        status: json['status']);
  }
}