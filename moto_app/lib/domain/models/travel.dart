import 'dart:convert';

List<Travel> travelsModelFromJson(String str) =>
    List<Travel>.from(json.decode(str).map((x) => Travel.fromJson(x)));

String travelsModelToJson(List<Travel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Travel {
  Travel({
    required this.id,
    required this.userId,
    required this.date,
    required this.initialLocation,
    required this.finalLocation,
    required this.distance,
  });

  final int id;
  final int userId;
  final DateTime date;
  final String initialLocation;
  final String finalLocation;
  final int distance;

  factory Travel.fromJson(Map<String, dynamic> json) {
    return Travel(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      initialLocation: json['initial_location'],
      finalLocation: json['final_location'],
      distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'initial_location': initialLocation,
      'final_location': finalLocation,
      'distance': distance,
    };
  }
}

