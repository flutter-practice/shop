import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/constants.dart';

class ProductsProvider with ChangeNotifier {
  final String _baseUrl = '${Constants.BASE_API_URL}/products';
  List<Product> _items = [];
  String _token;
  String _userId;

  ProductsProvider([this._token, this._userId, this._items = const []]);

  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();

  Future<void> loadProducts() async {
    final response = await http.get("$_baseUrl.json?auth=$_token");
    final favoritesResponse = await http.get(
        "${Constants.BASE_API_URL}/userFavorite/$_userId.json?auth=$_token");
    final favoriteMap = json.decode(favoritesResponse.body);
    Map<String, dynamic> data = json.decode(response.body);
    _items.clear();
    if (data != null) {
      data.forEach((productId, productData) {
        final isFavorite =
            favoriteMap == null ? false : favoriteMap[productId] ?? false;
        _items.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: isFavorite,
        ));
      });
      notifyListeners();
    }
    return Future.value();
  }

  // Add product to cart
  Future<void> addProduct(Product product) {
    // Save product in DB
    return http
        .post(
      "$_baseUrl.json?auth=$_token",
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
      }),
    )
        .then((response) {
      // Add product locally
      _items.add(Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      ));
      notifyListeners();
    });
  }

  Future<void> updateProduct(Product product) async {
    if (product == null || product.id == null) return;

    final productIndex = _items.indexWhere((prod) => prod.id == product.id);
    if (productIndex >= 0) {
      await http.patch(
        "$_baseUrl/${product.id}.json?auth=$_token",
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        }),
      );
      _items[productIndex] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
      final product = _items[productIndex];
      _items.removeWhere((prod) => prod.id == id);
      notifyListeners();
      final response =
          await http.delete("$_baseUrl/${product.id}.json?auth=$_token");
      // Error
      if (response.statusCode >= 400) {
        // Add product back to local list
        _items.insert(productIndex, product);
        notifyListeners();
        // Throw exception
        throw HttpException('Error on product deletion');
      }
    }
  }
}
