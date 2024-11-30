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
  final _editFormKey = GlobalKey<FormState>();
  final _addImageController = TextEditingController();
  final _addPriceController = TextEditingController();
  final _addLocationController = TextEditingController();
  final _addTypeController = TextEditingController();
  final _addHouseTypeController = TextEditingController();
  final _editImageController = TextEditingController();
  final _editPriceController = TextEditingController();
  final _editLocationController = TextEditingController();
  final _editTypeController = TextEditingController();
  final _editHouseTypeController = TextEditingController();

  @override
  void dispose() {
    _addImageController.dispose();
    _addPriceController.dispose();
    _addLocationController.dispose();
    _addTypeController.dispose();
    _addHouseTypeController.dispose();
    _editImageController.dispose();
    _editPriceController.dispose();
    _editLocationController.dispose();
    _editTypeController.dispose();
    _editHouseTypeController.dispose();
    super.dispose();
  }

  void _addHouse() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('tb_products').add({
        'image': _addImageController.text,
        'price': _addPriceController.text,
        'location': _addLocationController.text,
        'type': _addTypeController.text,
        'houseType': _addHouseTypeController.text,
        'status': 'available',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('House added successfully')),
      );
      _formKey.currentState!.reset();
    }
  }

  void _editHouse(String id, Map<String, dynamic> data) async {
    _editImageController.text = data['image'];
    _editPriceController.text = data['price'];
    _editLocationController.text = data['location'];
    _editTypeController.text = data['type'];
    _editHouseTypeController.text = data['houseType'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit House'),
          content: Form(
            key: _editFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _editImageController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _editPriceController,
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
                  controller: _editLocationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _editTypeController,
                  decoration: const InputDecoration(labelText: 'Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a type';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _editHouseTypeController,
                  decoration: const InputDecoration(labelText: 'House Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a house type';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_editFormKey.currentState!.validate()) {
                  await FirebaseFirestore.instance
                      .collection('tb_products')
                      .doc(id)
                      .update({
                    'image': _editImageController.text,
                    'price': _editPriceController.text,
                    'location': _editLocationController.text,
                    'type': _editTypeController.text,
                    'houseType': _editHouseTypeController.text,
                    'updated_at': FieldValue.serverTimestamp(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('House updated successfully')),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteHouse(String id) async {
    await FirebaseFirestore.instance.collection('tb_products').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('House deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _addImageController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an image URL';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _addPriceController,
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
                    controller: _addLocationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _addTypeController,
                    decoration: const InputDecoration(labelText: 'Type'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a type';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _addHouseTypeController,
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
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tb_products')
                        .orderBy('created_at', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final houses = snapshot.data!.docs;

                      return DataTable(
                        columns: const [
                          DataColumn(label: Text('Image')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Location')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('House Type')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: houses.map((house) {
                          return DataRow(cells: [
                            DataCell(Text(house['image'] != null &&
                                    house['image'].isNotEmpty
                                ? 'Image Link Uploaded'
                                : '')),
                            DataCell(Text(house['price'])),
                            DataCell(Text(house['location'])),
                            DataCell(Text(house['type'])),
                            DataCell(Text(house['houseType'])),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editHouse(house.id,
                                      house.data() as Map<String, dynamic>),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteHouse(house.id),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('.', '');
    if (text.isNotEmpty) {
      final formattedText =
          NumberFormat.decimalPattern().format(int.parse(text));
      return newValue.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
    return newValue;
  }
}
