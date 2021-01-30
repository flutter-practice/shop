import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/provider/auth_provider.dart';
import 'package:shop/provider/cart_provider.dart';
import 'package:shop/provider/order_provider.dart';
import 'package:shop/provider/products_provider.dart';
import 'package:shop/utils/app_routes.dart';
import 'package:shop/views/admin/product_form_view.dart';
import 'package:shop/views/admin/product_management.dart';
import 'package:shop/views/auth_home.dart';
import 'package:shop/views/auth_view.dart';
import 'package:shop/views/cart_view.dart';
import 'package:shop/views/orders_view.dart';
import 'package:shop/views/product_detail_view.dart';
import 'package:shop/views/products_overview_view.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => new AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (_) => new ProductsProvider(),
          update: (ctx, auth, previewsProducts) => new ProductsProvider(
              auth.token, auth.userId, previewsProducts.items),
        ),
        ChangeNotifierProvider(
          create: (_) => new CartProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (_) => new OrdersProvider(),
          update: (ctx, auth, previewsOrders) => new OrdersProvider(
              auth.token, auth.userId, previewsOrders.orders),
        ),
      ],
      child: MaterialApp(
        title: 'Minha Loja',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
        ),
        routes: {
          AppRoutes.AUTH_HOME: (ctx) => AuthOrHome(),
          AppRoutes.PRODUCT_DETAIL: (ctx) => ProductDetailView(),
          AppRoutes.CART: (ctx) => CartView(),
          AppRoutes.ORDERS: (ctx) => OrdersView(),
          AppRoutes.PRODUCTS_MANAGEMENT: (ctx) => ProductsManagement(),
          AppRoutes.PRODUCT_FORM: (ctx) => ProductFormView(),
        },
      ),
    );
  }
}
