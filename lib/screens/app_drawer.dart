import 'package:flutter/material.dart';
import 'package:my_shop/screens/orders_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../helpers/custom_route.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final auth = context.read<Auth>();

    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Menu'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              // Navigator.pushReplacementNamed(
              //   context,
              //   OrdersScreen.routeName,
              // );
              Navigator.pushReplacement(
                context,
                CustomRoute(
                  builder: (context) => OrdersScreen(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.pushNamed(
                context,
                UserProductsScreen.routeName,
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sign out'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/');
              context.read<Auth>().signOut();
            },
          ),
        ],
      ),
    );
  }
}
