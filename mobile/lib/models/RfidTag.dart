class RfidTag {
  final int? id;
  final String name;
  final String creationTime;

  const RfidTag({
    this.id,
    required this.name,
    required this.creationTime
  });

  factory RfidTag.fromJson(Map<String, dynamic> json) {
    return RfidTag(
      id: json['id'],
      name: json['name'],
      creationTime: json['creationTime']
    );
  }
}
