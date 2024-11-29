import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _typeController = TextEditingController();
  final _houseTypeController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _imageController.dispose();
    _locationController.dispose();
    _typeController.dispose();
    _houseTypeController.dispose();
    super.dispose();
  }

  void _addHouse() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('tb_products').add({
        'image': _imageController.text,
        'price': _priceController.text,
        'location': _locationController.text,
        'type': _typeController.text,
        'houseType': _houseTypeController.text,
        'status': 'available',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('House added successfully')),
      );
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _houseTypeController,
                decoration: const InputDecoration(labelText: 'House Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a house type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addHouse,
                child: const Text('Tambah Rumah'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('.', '');
    if (text.isNotEmpty) {
      final formattedText = NumberFormat.decimalPattern().format(int.parse(text));
      return newValue.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
    return newValue;
  }
}