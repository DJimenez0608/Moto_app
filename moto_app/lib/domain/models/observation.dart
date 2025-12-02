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
    final idValue = json['id'];
    final motorcycleIdValue = json['motorcycle_id'];
    final createdAtValue = json['created_at'];
    final updatedAtValue = json['updated_at'];

    DateTime parseDateTime(dynamic value) {
      if (value is DateTime) {
        return value;
      }
      final str = value.toString();
      try {
        return DateTime.parse(str);
      } catch (e) {
        // Si el formato no es ISO8601, intentar otros formatos comunes
        // PostgreSQL TIMESTAMP puede venir como "2024-01-01 12:00:00"
        if (str.contains(' ')) {
          final parts = str.split(' ');
          if (parts.length >= 2) {
            return DateTime.parse('${parts[0]}T${parts[1]}');
          }
        }
        rethrow;
      }
    }

    return Observation(
      id: idValue is int ? idValue : int.parse(idValue.toString()),
      motorcycleId: motorcycleIdValue is int
          ? motorcycleIdValue
          : int.parse(motorcycleIdValue.toString()),
      observation: json['observation'] as String,
      createdAt: parseDateTime(createdAtValue),
      updatedAt: parseDateTime(updatedAtValue),
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

