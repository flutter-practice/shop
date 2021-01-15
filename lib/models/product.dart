import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/utils/constants.dart';

class Product with ChangeNotifier {
  final String _baseUrl =
      '${Constants.BASE_API_URL}/products';
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite() async {
    isFavorite = !isFavorite;
    notifyListeners();
    // Persist change in DB
    final response = await http.patch(
      "$_baseUrl/$id.json",
      body: json.encode({'isFavorite': isFavorite}),
    );
    // Error
    if (response.statusCode >= 400) {
      // Toggle favorite back to its original value
      isFavorite = !isFavorite;
      notifyListeners();
      // Throw exception
      throw HttpException(
          'There was an error to mark this product as favorite, please try again later');
    }
  }
}
