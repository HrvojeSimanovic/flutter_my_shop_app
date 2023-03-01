import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String? authToken;
  final String? userId;
  List<OrderItem> _orders = [];

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://myshop-44253-default-rtdb.europe-west1.firebasedatabase.app/orders/${this.userId}.json?auth=${this.authToken}');
    final response = await http.get(url);
    if (json.decode(response.body) == null) return;
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    final List<OrderItem> loadedOrders = [];
    extractedData.forEach((orderId, orderItem) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderItem['amount'],
        dateTime: DateTime.parse(orderItem['dateTime']),
        products: List<CartItem>.from(orderItem['product'].map(
          (item) => CartItem(
              id: item['id'],
              title: item['title'],
              quantity: item['quantity'],
              price: item['price']),
        )),
      ));
    });
    this._orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timeStamp = DateTime.now();
    final url = Uri.parse(
        'https://myshop-44253-default-rtdb.europe-west1.firebasedatabase.app/orders/${this.userId}.json?auth=${this.authToken}');
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'product': cartProducts
              .map((cartProduct) => {
                    'id': cartProduct.id,
                    'title': cartProduct.title,
                    'quantity': cartProduct.quantity,
                    'price': cartProduct.price,
                  })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }

  void removeOrder(String orderId) {
    _orders.remove(orderId);
    notifyListeners();
  }
}
