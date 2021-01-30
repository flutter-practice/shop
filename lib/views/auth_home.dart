import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/provider/auth_provider.dart';
import 'package:shop/views/auth_view.dart';
import 'package:shop/views/products_overview_view.dart';

class AuthOrHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of(context);
    return FutureBuilder(
      future: auth.tryAutoLogin(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        else if (snapshot.error != null)
          return Center(child: Text('Unexpected error'));
        else
          return auth.isAuth ? ProductsOverviewView() : AuthView();
      },
    );
  }
}
