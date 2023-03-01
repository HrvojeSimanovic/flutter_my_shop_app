import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String imageURL;
  final String productId;

  const UserProductItem(
    this.title,
    this.imageURL,
    this.productId,
  );

  @override
  Widget build(BuildContext context) {
    final productsData = context.read<Products>();
    final scaffold = ScaffoldMessenger.of(context);

    return Card(
      shadowColor: Theme.of(context).primaryColor,
      elevation: 5,
      child: ListTile(
        title: Text(this.title),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(this.imageURL),
        ),
        trailing: Container(
          width: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.edit,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    EditProductScreen.routeName,
                    arguments: this.productId,
                  );
                },
                color: Theme.of(context).primaryColor,
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                ),
                onPressed: () async {
                  try {
                    await productsData.deleteProduct(this.productId);
                  } catch (error) {
                    scaffold.showSnackBar(SnackBar(
                      content: Text('$error', textAlign: TextAlign.center),
                      duration: Duration(milliseconds: 1000),
                    ));
                  }
                },
                color: Theme.of(context).errorColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
