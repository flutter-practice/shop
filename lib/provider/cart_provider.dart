import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shop/models/product.dart';

class CartItem with ChangeNotifier {
  final String id;
  final String title;
  final String imageUrl;
  final int quantity;
  final double price;
  final String productId;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.imageUrl,
    @required this.price,
    @required this.productId,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, CartItem> get item => {..._items};

  int get itemCount {
    return _items.length;
  }

  double get totalCartPrice {
    double total = 0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id))
      _items.update(
          product.id,
          (existingItem) => CartItem(
                id: existingItem.id,
                title: existingItem.title,
                quantity: existingItem.quantity + 1,
                price: existingItem.price,
                imageUrl: existingItem.imageUrl,
                productId: existingItem.productId,
              ));
    else
      _items.putIfAbsent(
          product.id,
          () => CartItem(
                id: Random().nextDouble().toString(),
                title: product.title,
                price: product.price,
                quantity: 1,
                imageUrl: product.imageUrl,
                productId: product.id,
              ));
    // Notify listeners
    notifyListeners();
  }

  void removeSingleItem(productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId].quantity == 1)
      _items.remove(productId);
    else
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          quantity: existingItem.quantity - 1,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
          productId: existingItem.productId,
        ),
      );
    // Notify listeners
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((key, value) => value.productId == productId);
    // Notify listeners
    notifyListeners();
  }

  void clear() {
    _items = {};
    // Notify listeners
    notifyListeners();
  }
}
