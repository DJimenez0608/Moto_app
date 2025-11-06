import 'dart:convert';

List<Maintenance> maintenanceModelFromJson(String str) =>
    List<Maintenance>.from(json.decode(str).map((x) => Maintenance.fromJson(x)));

String maintenanceModelToJson(List<Maintenance> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Maintenance {
  Maintenance({
    required this.id,
    required this.motorcycleId,
    required this.date,
    required this.description,
    required this.cost,
  });

  final int id;
  final int motorcycleId;
  final DateTime date;
  final String description;
  final double cost;

  factory Maintenance.fromJson(Map<String, dynamic> json) {
    return Maintenance(
      id: json['id'],
      motorcycleId: json['motorcycle_id'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      cost: (json['cost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motorcycle_id': motorcycleId,
      'date': date.toIso8601String().split('T')[0],
      'description': description,
      'cost': cost,
    };
  }
}

