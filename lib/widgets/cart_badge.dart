import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';

import '../screens/cart_screen.dart';

import '../providers/cart.dart';

class CartBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (_, cartData, childWidget) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Badge(
          badgeContent: Text(
            cartData.itemCount.toString(),
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
          child: childWidget,
          badgeColor: Theme.of(context).accentColor,
          animationType: BadgeAnimationType.scale,
          animationDuration: const Duration(milliseconds: 200),
          position: BadgePosition(top: -4, end: 5),
          alignment: Alignment.center,
        ),
      ),
      child: IconButton(
        icon: Icon(Icons.shopping_cart),
        onPressed: () {
          Navigator.of(context).pushNamed(
            CartScreen.routeName,
          );
        },
      ),
    );
  }
}
