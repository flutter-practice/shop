import 'package:flutter/material.dart';
import 'package:shop/utils/app_routes.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Welcome!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Store'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.HOME);
            },
          ),
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text('Orders'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.ORDERS);
            },
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(AppRoutes.PRODUCTS_MANAGEMENT);
            },
          ),
        ],
      ),
    );
  }
}
