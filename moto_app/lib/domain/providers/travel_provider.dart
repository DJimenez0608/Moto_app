import 'package:flutter/material.dart';
import 'package:moto_app/domain/models/travel.dart';
import 'package:moto_app/features/auth/data/datasources/travel_http_service.dart';

class TravelProvider extends ChangeNotifier {
  List<Travel> _travels = [];
  List<Travel> get travels => _travels;

  void setTravels(List<Travel> travels) {
    _travels = travels;
    notifyListeners();
  }

  Future<void> getTravels(id) async {
    final travels = await TravelHttpService().getTravels(id);
  }
}
