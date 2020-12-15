import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shop/provider/cart_provider.dart';

class Order {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime date;

  const Order({
    @required this.id,
    @required this.total,
    @required this.products,
    @required this.date,
  });
}

class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => [..._orders];

  void addOrder(CartProvider cart) {
    // final combine = (t, i) => t + (i.price * i.quantity);
    // final total = products.fold(0.0, combine);
    _orders.insert(
      0,
      Order(
          id: Random().nextDouble().toString(),
          total: cart.totalCartPrice,
          date: DateTime.now(),
          products: cart.item.values.toList()),
    );

    notifyListeners();
  }
}
