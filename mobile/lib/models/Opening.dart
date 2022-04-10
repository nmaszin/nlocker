class Opening {
  final int? id;
  final String time;
  final int lockerId;
  final int? rfidId;
  final String? name;

  const Opening({
    this.id,
    required this.time,
    required this.lockerId,
    this.rfidId,
    this.name
  });

  factory Opening.fromJson(Map<String, dynamic> json) {
    return Opening(
      id: json['id'],
      time: json['time'],
      lockerId: json['lockerId'],
      rfidId: json['rfidId'],
      name: json['name']
    );
  }
}
