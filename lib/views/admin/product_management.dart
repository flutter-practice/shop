import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/components/product_item.dart';
import 'package:shop/provider/products_provider.dart';
import 'package:shop/utils/app_routes.dart';

class ProductsManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.PRODUCT_FORM,
              );
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: productsProvider.items.length,
          itemBuilder: (ctx, i) {
            return Column(
              children: [
                ProductItem(productsProvider.items[i]),
                Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
