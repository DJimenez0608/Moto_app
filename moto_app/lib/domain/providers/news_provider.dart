import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moto_app/domain/models/news.dart';
import 'package:moto_app/features/auth/data/datasources/serApi_http_service.dart';

class NewsProvider extends ChangeNotifier {
  static const String _lastUpdateKey = 'last_news_update';
  static const int _cacheDurationHours = 24;

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

  Future<DateTime?> _getLastUpdateTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateString = prefs.getString(_lastUpdateKey);
      if (lastUpdateString == null) {
        return null;
      }
      return DateTime.parse(lastUpdateString);
    } catch (e) {
      // Si hay error al leer, retornar null para forzar actualización
      return null;
    }
  }

  Future<void> _saveLastUpdateTime(DateTime dateTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUpdateKey, dateTime.toIso8601String());
    } catch (e) {
      // Si hay error al guardar, continuar sin guardar
      // No es crítico, solo afectará la optimización de peticiones
    }
  }

  bool _shouldRefresh(DateTime? lastUpdate) {
    if (lastUpdate == null) {
      return true; // Primera vez, siempre refrescar
    }
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference.inHours >= _cacheDurationHours;
  }

  Future<void> loadNews({bool forceRefresh = false}) async {
    try {
      // Si no es forzado, verificar caché
      if (!forceRefresh) {
        final lastUpdate = await _getLastUpdateTime();
        // Si hay noticias y no han pasado 24 horas, mantener las actuales
        if (_news.isNotEmpty && !_shouldRefresh(lastUpdate)) {
          // No han pasado 24 horas y hay noticias, mantener noticias actuales
          return;
        }
        // Si no hay noticias, siempre intentar cargar (aunque no hayan pasado 24h)
      }

      // Hacer petición a la API
      final allNews = await SerApiHttpService().getNews();
      // Filtrar solo las primeras 5 noticias (position 1-5)
      // Nota: El filtrado por position se hace en el servicio HTTP
      setNews(allNews);

      // Guardar fecha de actualización exitosa
      await _saveLastUpdateTime(DateTime.now());
    } catch (error) {
      // En caso de error, mantener noticias en caché si existen
      // No limpiar _news para mantener las noticias anteriores
      // No actualizar la fecha de última actualización
      if (_news.isEmpty) {
        // Solo limpiar si no hay noticias previas
        _news = [];
        notifyListeners();
      }
      // Log del error para debugging (solo en modo debug)
      debugPrint('Error al cargar noticias: $error');
      rethrow;
    }
  }

  Future<void> forceRefresh() async {
    await loadNews(forceRefresh: true);
  }
}

