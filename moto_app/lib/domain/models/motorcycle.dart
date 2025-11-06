import 'dart:convert';

List<Motorcycle> motorcyclesModelFromJson(String str) =>
    List<Motorcycle>.from(json.decode(str).map((x) => Motorcycle.fromJson(x)));

String motorcyclesModelToJson(List<Motorcycle> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Motorcycle {
  Motorcycle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.power,
    required this.torque,
    required this.type,
    this.displacement,
    required this.fuelCapacity,
    required this.weight,
    required this.userId,
  });

  final int id;
  final String make;
  final String model;
  final int year;
  final int power;
  final int torque;
  final String type;
  final int? displacement;
  final String fuelCapacity;
  final int weight;
  final int userId;

  factory Motorcycle.fromJson(Map<String, dynamic> json) {
    return Motorcycle(
      id: json['id'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      power: json['power'],
      torque: json['torque'],
      type: json['type'],
      displacement: json['displacement'],
      fuelCapacity: json['fuel_capacity'],
      weight: json['weight'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'power': power,
      'torque': torque,
      'type': type,
      'displacement': displacement,
      'fuel_capacity': fuelCapacity,
      'weight': weight,
      'user_id': userId,
    };
  }
}

