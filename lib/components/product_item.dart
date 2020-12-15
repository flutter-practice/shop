import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/provider/products_provider.dart';
import 'package:shop/utils/app_routes.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  const ProductItem(this.product);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      title: Text(product.title),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.PRODUCT_FORM,
                  arguments: product,
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: Text('Are you sure?'),
                        content: Text(
                            'Do you want to remove this product from your store?'),
                        actions: [
                          FlatButton(
                            child: Text('No'),
                            onPressed: () => Navigator.of(ctx).pop(false),
                          ),
                          FlatButton(
                            child: Text('Yes'),
                            onPressed: () => Navigator.of(ctx).pop(true),
                          ),
                        ],
                      );
                    }).then((value) {
                  if (value) {
                    Provider.of<ProductsProvider>(
                      context,
                      listen: false,
                    ).deleteProduct(product.id);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
