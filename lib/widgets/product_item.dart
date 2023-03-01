import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = context.read<Product>();
    final cart = context.read<Cart>();
    final auth = context.read<Auth>();

    final snackBar = SnackBar(
      // behavior: SnackBarBehavior.floating,
      content: Text(
        'Added item to cart!',
      ),
      duration: Duration(
        seconds: 2,
      ),
      elevation: 30,
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () => cart.removeSingleItem(product.id!),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Hero(
            tag: product.id!,
            child: FadeInImage.assetNetwork(
              placeholder: ('assets/images/product-placeholder.png'),
              image: (product.imageURL),
              fit: BoxFit.contain,
            ),
          ),
        ),
        footer: Consumer<Product>(
          builder: (ctx, product, child) => GridTileBar(
            backgroundColor: Colors.black87,
            leading: IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () {
                product.toggleFavoriteStatus(auth.token!, auth.userId!);
              },
            ),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                cart.addItem(product.id!, product.price, product.title);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
              },
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
