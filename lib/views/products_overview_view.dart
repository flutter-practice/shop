import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/components/badge.dart';
import 'package:shop/components/product_grid.dart';
import 'package:shop/provider/cart_provider.dart';
import 'package:shop/provider/products_provider.dart';
import 'package:shop/utils/app_routes.dart';

enum FilterOptions { Favorite, All }

class ProductsOverviewView extends StatefulWidget {
  @override
  _ProductsOverviewViewState createState() => _ProductsOverviewViewState();
}

class _ProductsOverviewViewState extends State<ProductsOverviewView> {
  bool _showFavoriteOnly = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load data
    Provider.of<ProductsProvider>(context, listen: false)
        .loadProducts()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('E-Shop'), actions: <Widget>[
        PopupMenuButton(
          onSelected: (FilterOptions selectedValue) {
            setState(() {
              _showFavoriteOnly = selectedValue == FilterOptions.Favorite;
            });
          },
          icon: Icon(Icons.filter_list_alt),
          itemBuilder: (_) => [
            PopupMenuItem(
              child: Text('Favorite only'),
              value: FilterOptions.Favorite,
            ),
            PopupMenuItem(
              child: Text('All'),
              value: FilterOptions.All,
            )
          ],
        ),
        Consumer<CartProvider>(
          builder: (ctx, cart, _) => Badge(
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.CART);
              },
            ),
            value: cart.itemCount.toString(),
          ),
        )
      ]),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              child: ProductGrid(_showFavoriteOnly),
              onRefresh: () =>
                  Provider.of<ProductsProvider>(context, listen: false)
                      .loadProducts(),
            ),
      drawer: AppDrawer(),
    );
  }
}
