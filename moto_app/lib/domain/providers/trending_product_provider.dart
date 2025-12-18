import 'package:flutter/foundation.dart';
import 'package:moto_app/domain/models/trending_product.dart';
import 'package:moto_app/features/auth/data/datasources/trending_product_http_service.dart';

class TrendingProductProvider extends ChangeNotifier {
  List<TrendingProduct> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TrendingProduct> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTrendingProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await TrendingProductHttpService().getTrendingProducts();
      if (kDebugMode) {
        debugPrint('Productos cargados: ${_products.length}');
      }
    } catch (e) {
      _products = [];
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('Error al cargar productos: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProducts() {
    _products = [];
    _errorMessage = null;
    notifyListeners();
  }
}

