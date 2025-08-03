import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:elitebazaar/model/product.dart';
import 'package:http/http.dart' as http;

class ProductController with ChangeNotifier {
  List<Product> _productsList = [];
  final List<Product> _cartItems = [];
  final List<Product> _favoriteItems = [];

  bool _isLoading = false;
  String? _error;

  List<Product> get productsList => _productsList;
  List<Product> get cartItems => _cartItems;
  List<Product> get favoriteItems => _favoriteItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductController() {
    fetchProducts();
  }

  double get totalCartAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.price);
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    const String apiUrl = "https://fakestoreapi.com/products";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _productsList = data.map((json) => Product.fromJson(json)).toList();
      } else {
        _error = "Failed to load products: Status code ${response.statusCode}";
      }
    } catch (e) {
      _error = "Failed to connect to the server: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(Product product) {
    if (!_cartItems.contains(product)) {
      _cartItems.add(product);
      notifyListeners();
    }
  }

  void removeFromCart(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  void addToFavorites(Product product) {
    if (!_favoriteItems.contains(product)) {
      _favoriteItems.add(product);
      notifyListeners();
    }
  }

  void removeFromFavorites(Product product) {
    _favoriteItems.remove(product);
    notifyListeners();
  }

  bool isProductInCart(Product product) {
    return _cartItems.contains(product);
  }

  bool isProductInFavorites(Product product) {
    return _favoriteItems.contains(product);
  }
}
