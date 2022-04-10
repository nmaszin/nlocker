import 'dart:math';

class Locker {
  final int? id;
  final String name;
  final bool connected;

  const Locker({
    this.id,
    required this.name,
    required this.connected
  });

  factory Locker.fromJson(Map<String, dynamic> json) {
    return Locker(
      id: json['id'],
      name: json['name'],
      connected: json['connected']
    );
  }
}
