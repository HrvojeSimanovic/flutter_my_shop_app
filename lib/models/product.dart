import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageURL;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageURL,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    final oldStatus = this.isFavorite;

    void _setFavValue(bool newValue) {
      this.isFavorite = newValue;
      notifyListeners();
    }

    this.isFavorite = !this.isFavorite;
    this.notifyListeners();

    final url = Uri.parse(
        'https://myshop-44253-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/${this.id}.json?auth=$authToken');

    try {
      final response = await http.put(
        url,
        body: json.encode(this.isFavorite),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
