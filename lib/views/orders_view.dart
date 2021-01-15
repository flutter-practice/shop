import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/components/order_item.dart';
import 'package:shop/provider/order_provider.dart';

class OrdersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<OrdersProvider>(context, listen: false).loadOrders(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else if (snapshot.error != null)
            return Center(
                child: Text(
                    'Sorry, we were not able to load your orders. Please try again later.'));
          else
            return Consumer<OrdersProvider>(
              builder: (ctx, ordersProvider, child) {
                return ListView.builder(
                  itemCount: ordersProvider.orders.length,
                  itemBuilder: (ctx, index) =>
                      OrderItem(ordersProvider.orders[index]),
                );
              },
            );
        },
      ),
    );
  }
}
