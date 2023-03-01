import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../models/product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  final String? authToken;
  final String? userId;
  List<Product> _items = [];

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [...this._items];
  }

  List<Product> get favoriteItems {
    return this._items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return this._items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final String filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="${this.userId}"' : '';

    var url = Uri.parse(
        'https://myshop-44253-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=${this.authToken}$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (json.decode(response.body) == null) return;

      url = Uri.parse(
          'https://myshop-44253-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/${this.userId}.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach(
        (prodId, prodData) {
          loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageURL: prodData['imageURL'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
          ));
        },
      );
      this._items = loadedProducts;
      notifyListeners();
    } catch (error) {
      // throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://myshop-44253-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=${this.authToken}');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageURL': product.imageURL,
          'price': product.price,
          'creatorId': this.userId,
        }),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageURL: product.imageURL,
      );
      this._items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product updatedProduct) async {
    final prodIndex = this._items.indexWhere((prod) => prod.id == id);
    final url = Uri.parse(
        'https://myshop-44253-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=${this.authToken}');
    http.patch(url,
        body: json.encode({
          'title': updatedProduct.title,
          'description': updatedProduct.description,
          'imageURL': updatedProduct.imageURL,
          'price': updatedProduct.price,
        }));
    this._items[prodIndex] = updatedProduct;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://myshop-44253-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=${this.authToken}');

    final itemToDeleteIndex = this._items.indexWhere((item) => item.id == id);
    var itemToDelete = this._items[itemToDeleteIndex];

    this._items.removeAt(itemToDeleteIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      this._items.insert(itemToDeleteIndex, itemToDelete);
      notifyListeners();
      throw HttpException('Deleting faled!');
    }
  }
}




// Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageURL:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageURL:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageURL:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageURL:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),