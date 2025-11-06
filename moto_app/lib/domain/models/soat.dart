import 'dart:convert';

List<Soat> soatModelFromJson(String str) =>
    List<Soat>.from(json.decode(str).map((x) => Soat.fromJson(x)));

String soatModelToJson(List<Soat> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Soat {
  Soat({
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

  factory Soat.fromJson(Map<String, dynamic> json) {
    return Soat(
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

