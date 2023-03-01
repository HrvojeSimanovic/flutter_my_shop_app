import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  late String _usersUrl = '';
  late FocusNode _imageUrlFocusNode;
  var _isInit = true;
  var _isLoading = false;

  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageURL: '',
  );

  var _initValue = {
    'id': '',
    'title': '',
    'description': '',
    'price': '',
    'imageURL': '',
  };

  void _usersUrlHandler() {
    setState(() {
      _usersUrl = _imageUrlController.text;
    });
  }

  Future<void> _errorHandler() {
    return showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occured!'),
        content: Text('Something went wrong!'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          )
        ],
      ),
    );
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id != '') {
      await context
          .read<Products>()
          .updateProduct(_initValue['id']!, _editedProduct);
    } else {
      try {
        await context.read<Products>().addProduct(_editedProduct);
      } catch (error) {
        await _errorHandler();
      }
      setState(() {
        _isLoading = false;
      });
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode = FocusNode();
    _imageUrlFocusNode.addListener(_usersUrlHandler);
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_usersUrlHandler);
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String?;

      if (productId != null) {
        final _editedProduct = context.read<Products>().findById(productId);
        _initValue = {
          'id': _editedProduct.id!,
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          // 'imageURL': _editedProduct.imageURL,
          'imageURL': '',
        };
        _imageUrlController.text = _editedProduct.imageURL;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: _initValue['title'],
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (titleValue) {
                          if (titleValue == null || titleValue.isEmpty) {
                            return 'Please enter title';
                          }
                          return null;
                        },
                        onSaved: (titleValue) {
                          _editedProduct = Product(
                            id: _initValue['id'],
                            title: titleValue.toString(),
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageURL: _editedProduct.imageURL,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                      ),
                      Divider(),
                      TextFormField(
                        initialValue: _initValue['price'],
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (priceValue) {
                          if (priceValue == null || priceValue.isEmpty) {
                            return 'Please enter some number';
                          }
                          if (double.tryParse(priceValue) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(priceValue) <= 0) {
                            return 'Please enter number greater than 0';
                          }
                          return null;
                        },
                        onSaved: (priceValue) {
                          _editedProduct = Product(
                            id: _initValue['id'],
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: double.parse(priceValue!),
                            imageURL: _editedProduct.imageURL,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                      ),
                      Divider(),
                      TextFormField(
                        initialValue: _initValue['description'],
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        maxLength: 250,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        keyboardType: TextInputType.multiline,
                        validator: (descriptionValue) {
                          if (descriptionValue == null ||
                              descriptionValue.isEmpty) {
                            return 'Please enter description';
                          }
                          if (descriptionValue.length < 10) {
                            return 'Should be at least 10 characters long';
                          }
                          return null;
                        },
                        onSaved: (descriptionValue) {
                          _editedProduct = Product(
                            id: _initValue['id'],
                            title: _editedProduct.title,
                            description: descriptionValue!,
                            price: _editedProduct.price,
                            imageURL: _editedProduct.imageURL,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                      ),
                      Divider(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: _usersUrl.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Enter URL',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                : Image.network(_usersUrl),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onEditingComplete: () {
                                _usersUrlHandler();
                                // _saveForm();
                              },
                              // onFieldSubmitted: (_) => _saveForm(),
                              validator: (urlValue) {
                                if (urlValue == null || urlValue.isEmpty) {
                                  return 'Please enter image URL';
                                }
                                if ((!urlValue.startsWith('http') &&
                                        !urlValue.startsWith('https')) ||
                                    (!urlValue.endsWith('.jpg') &&
                                        !urlValue.endsWith('.jpeg') &&
                                        !urlValue.endsWith('.png'))) {
                                  return 'Please enter valid URL';
                                }
                                return null;
                              },
                              onSaved: (urlValue) {
                                _editedProduct = Product(
                                  id: _initValue['id'],
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imageURL: urlValue!,
                                  isFavorite: _editedProduct.isFavorite,
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}











  // void _saveForm() {
  //   if (_formKey.currentState!.validate()) {
  //     final productsData = context.read<Products>();

  //     _formKey.currentState!.save();
  //     productsData.addProduct(_editedProduct);
  //     Navigator.pop(context);
  //   }
  //   return;
  // }