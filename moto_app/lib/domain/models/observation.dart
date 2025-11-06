import 'dart:convert';

List<Observation> observationsModelFromJson(String str) =>
    List<Observation>.from(json.decode(str).map((x) => Observation.fromJson(x)));

String observationsModelToJson(List<Observation> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Observation {
  Observation({
    required this.id,
    required this.motorcycleId,
    required this.observation,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int motorcycleId;
  final String observation;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      id: json['id'],
      motorcycleId: json['motorcycle_id'],
      observation: json['observation'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motorcycle_id': motorcycleId,
      'observation': observation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

