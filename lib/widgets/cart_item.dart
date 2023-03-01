import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/delete_alert_dialog.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  const CartItem(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.title,
  );

  Widget build(BuildContext context) {
    final cart = context.read<Cart>();

    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => DeleteAlertDialog(),
        );
      },
      key: ValueKey(this.id),
      background: Container(
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(
          right: 20,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        color: Theme.of(context).errorColor,
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => {
        cart.removeItem(this.productId),
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                  right: 4,
                ),
                child: FittedBox(
                  child: Text(
                    '${this.price}',
                  ),
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            title: Text(this.title),
            subtitle: Text(
              'Total: ${(this.price * this.quantity).toStringAsFixed(2)} \$',
            ),
            trailing: Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      cart.addItem(productId, price, title);
                    },
                    icon: Icon(Icons.add),
                    color: Colors.black,
                    iconSize: 15.0,
                  ),
                  Text(
                    '${this.quantity} x',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      cart.removeSingleItem(productId);
                    },
                    icon: Icon(Icons.remove),
                    color: Colors.black,
                    iconSize: 15.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
