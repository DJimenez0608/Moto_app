import 'dart:convert';

List<Technomechanical> technomechanicalModelFromJson(String str) =>
    List<Technomechanical>.from(json.decode(str).map((x) => Technomechanical.fromJson(x)));

String technomechanicalModelToJson(List<Technomechanical> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Technomechanical {
  Technomechanical({
    required this.id,
    required this.motorcycleId,
    required this.startDate,
    required this.endDate,
    required this.cost,
  });

  final int id;
  final int motorcycleId;
  final DateTime startDate;
  final DateTime endDate;
  final double cost;

  factory Technomechanical.fromJson(Map<String, dynamic> json) {
    return Technomechanical(
      id: json['id'],
      motorcycleId: json['motorcycle_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      cost: (json['cost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motorcycle_id': motorcycleId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'cost': cost,
    };
  }
}

