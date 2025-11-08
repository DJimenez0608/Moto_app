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
    final idValue = json['id'];
    final motorcycleIdValue = json['motorcycle_id'];
    final costValue = json['cost'];

    return Maintenance(
      id: idValue is int ? idValue : int.parse(idValue.toString()),
      motorcycleId: motorcycleIdValue is int
          ? motorcycleIdValue
          : int.parse(motorcycleIdValue.toString()),
      date: DateTime.parse(json['date'].toString()),
      description: json['description'] as String,
      cost: costValue is num
          ? costValue.toDouble()
          : double.parse(costValue.toString()),
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

