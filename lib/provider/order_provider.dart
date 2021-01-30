import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/provider/cart_provider.dart';
import 'package:shop/utils/constants.dart';

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
  final String _baseUrl = '${Constants.BASE_API_URL}/orders';
  List<Order> _orders = [];
  String _token;
  String _userId;

  List<Order> get orders => [..._orders];

  OrdersProvider([this._token, this._userId, this._orders = const []]);

  Future<void> loadOrders() async {
    final response = await http.get("$_baseUrl/$_userId.json?auth=$_token");
    Map<String, dynamic> data = json.decode(response.body);
    _orders.clear();
    if (data != null) {
      data.forEach((orderId, orderData) {
        _orders.add(Order(
          id: orderId,
          total: orderData['total'],
          date: DateTime.parse(orderData['date']),
          products: (orderData['products'] as List<dynamic>).map((item) {
            return CartItem(
              id: item['id'],
              price: item['price'],
              productId: item['productId'],
              quantity: item['quantity'],
              title: item['title'],
              imageUrl: item['imageUrl'],
            );
          }).toList(),
        ));
      });
      notifyListeners();
    }
    _orders = _orders.reversed.toList();
    return Future.value();
  }

  Future<void> addOrder(CartProvider cart) async {
    final date = DateTime.now();
    final response = await http.post(
      "$_baseUrl/$_userId.json?auth=$_token",
      body: json.encode({
        'total': cart.totalCartPrice,
        'date': date.toIso8601String(),
        'products': cart.item.values
            .map((cartItem) => {
                  'id': cartItem.id,
                  'productId': cartItem.productId,
                  'imageUrl': cartItem.imageUrl,
                  'title': cartItem.title,
                  'quantity': cartItem.quantity,
                  'price': cartItem.price,
                })
            .toList()
      }),
    );

    _orders.insert(
      0,
      Order(
          id: json.decode(response.body)['name'],
          total: cart.totalCartPrice,
          date: date,
          products: cart.item.values.toList()),
    );

    notifyListeners();
  }
}
