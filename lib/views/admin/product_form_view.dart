import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/provider/products_provider.dart';

class ProductFormView extends StatefulWidget {
  @override
  _ProductFormViewState createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageURLFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _formData = Map<String, Object>();

  @override
  void initState() {
    super.initState();
    _imageURLFocusNode.addListener(_updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final product = ModalRoute.of(context).settings.arguments as Product;
    if (_formData.isEmpty && product != null) {
      _formData['id'] = product.id;
      _formData['title'] = product.title;
      _formData['description'] = product.description;
      _formData['price'] = product.price;
      _formData['imageUrl'] = product.imageUrl;
      _imageUrlController.text = product.imageUrl;
    } else
      _formData['price'] = '';
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageURLFocusNode.removeListener(_updateImage);
    _imageURLFocusNode.dispose();
  }

  void _updateImage() {
    if (isValidImageUrl(_imageUrlController.text)) {
      setState(() {});
    }
  }

  bool isValidImageUrl(String url) {
    bool isValidProtocol = url.toLowerCase().startsWith('http://') ||
        url.toLowerCase().startsWith('https://');
    bool endsWithPng = url.toLowerCase().endsWith('.png');
    bool endsWithJpg = url.toLowerCase().endsWith('.jpg');
    bool endsWithJpeg = url.toLowerCase().endsWith('.jpeg');
    bool endsWithGif = url.toLowerCase().endsWith('.gif');

    return isValidProtocol &&
        (endsWithPng || endsWithJpg || endsWithJpeg || endsWithGif);
  }

  void _saveForm() {
    bool isValid = _form.currentState.validate();
    if (!isValid) return;
    _form.currentState.save();
    final product = Product(
      id: _formData['id'],
      title: _formData['title'],
      description: _formData['description'],
      price: _formData['price'],
      imageUrl: _formData['imageUrl'],
    );

    final productsProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    if (_formData['id'] == null)
      productsProvider.addProduct(product);
    else
      productsProvider.updateProduct(product);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product form'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _saveForm(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _formData['title'],
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (value) => _formData['title'] = value,
                validator: (value) {
                  if (value.trim().isEmpty)
                    return 'Please inform the product title';
                  else if (value.trim().length < 3)
                    return 'Please inform a title with at least 3 characters';
                  return null;
                },
              ),
              TextFormField(
                initialValue: _formData['price'].toString(),
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                focusNode: _priceFocusNode,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                onSaved: (value) => _formData['price'] = double.parse(value),
                validator: (value) {
                  var newPrice = double.tryParse(value);
                  if (value.trim().isEmpty || newPrice == null || newPrice <= 0)
                    return 'Please enter a valid price';
                  else
                    return null;
                },
              ),
              TextFormField(
                initialValue: _formData['description'],
                decoration: InputDecoration(labelText: 'Description'),
                focusNode: _descriptionFocusNode,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_imageURLFocusNode);
                },
                onSaved: (value) => _formData['description'] = value,
                validator: (value) {
                  if (value.trim().isEmpty || value.length < 10)
                    return 'Please enter a product description at least 10 characters long';
                  else
                    return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                        decoration: InputDecoration(labelText: 'Image URL'),
                        focusNode: _imageURLFocusNode,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        onFieldSubmitted: (_) {
                          _saveForm();
                        },
                        onSaved: (value) => _formData['imageUrl'] = value,
                        validator: (value) {
                          if (!isValidImageUrl(value) || value.trim().isEmpty)
                            return 'Please inform a valid image';
                          else
                            return null;
                        }),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(top: 8, left: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? Text('Enter URL')
                        : FittedBox(
                            fit: BoxFit.fitWidth,
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(minWidth: 1, minHeight: 1),
                              child: Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
