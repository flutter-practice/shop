import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/provider/cart_provider.dart';

class CartItemComponent extends StatelessWidget {
  final CartItem cartItem;
  CartItemComponent(this.cartItem);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(cartItem.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) {
        return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Are you sure?'),
                content:
                    Text('Do you want to remove this item from your cart?'),
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
            });
      },
      onDismissed: (_) {
        Provider.of<CartProvider>(context, listen: false)
            .removeItem(cartItem.productId);
      },
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(cartItem.imageUrl),
              ),
              title: Text(cartItem.title),
              subtitle: Text('Price: ${cartItem.price}'),
              trailing: Text('${cartItem.quantity}x'),
            ),
          )),
    );
  }
}
