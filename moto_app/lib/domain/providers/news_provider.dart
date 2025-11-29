import 'package:flutter/material.dart';
import 'package:moto_app/domain/models/news.dart';
import 'package:moto_app/features/auth/data/datasources/serApi_http_service.dart';

class NewsProvider extends ChangeNotifier {
  List<News> _news = [];
  List<News> get news => List.unmodifiable(_news);

  void setNews(List<News> news) {
    _news = news;
    notifyListeners();
  }

  void clearNews() {
    _news = [];
    notifyListeners();
  }

  Future<void> loadNews() async {
    try {
      final allNews = await SerApiHttpService().getNews();
      // Filtrar solo las primeras 5 noticias (position 1-5)
      // Nota: El filtrado por position se hace en el servicio HTTP
      setNews(allNews);
    } catch (error) {
      // En caso de error, mantener lista vacía
      _news = [];
      notifyListeners();
      rethrow;
    }
  }
}

