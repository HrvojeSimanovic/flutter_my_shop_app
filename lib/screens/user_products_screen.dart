import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../screens/edit_product_screen.dart';
import '../screens/app_drawer.dart';
import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-product';

  Future<void> _onRefreshHandler(BuildContext context) async {
    await context.read<Products>().fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, EditProductScreen.routeName,
                  arguments: null);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _onRefreshHandler(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.done
                ? RefreshIndicator(
                    onRefresh: () => _onRefreshHandler(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Consumer<Products>(
                        builder: (context, productsData, _) => ListView.builder(
                          itemCount: productsData.items.length,
                          itemBuilder: (_, int index) => UserProductItem(
                            productsData.items[index].title,
                            productsData.items[index].imageURL,
                            productsData.items[index].id!,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
      ),
    );
  }
}
