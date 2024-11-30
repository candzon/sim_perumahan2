import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormBooking extends StatefulWidget {
  final String productId;
  final String uid;

  const FormBooking({super.key, required this.productId, required this.uid});

  @override
  _FormBookingState createState() => _FormBookingState();
}

class _FormBookingState extends State<FormBooking> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _nomorKtpController = TextEditingController();
  File? _buktiTransfer;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _buktiTransfer = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _noTelpController.dispose();
    _nomorKtpController.dispose();
    super.dispose();
  }

  void _addBooking() async {
    if (_formKey.currentState!.validate()) {
      // Fetch product details
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('tb_products')
          .doc(widget.productId)
          .get();

      if (productSnapshot.exists) {
        var productData = productSnapshot.data() as Map<String, dynamic>;
        var price = productData['price'];

        await FirebaseFirestore.instance.collection('tb_booking').add({
          'image': _buktiTransfer?.path,
          'nama': _namaController.text,
          'location': _alamatController.text,
          'no_telp': _noTelpController.text,
          'nomor_ktp': _nomorKtpController.text,
          'status': 'pending',
          'product_id': widget.productId,
          'uid': widget.uid,
          'price': price,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        // Update product status to pending
        await FirebaseFirestore.instance
            .collection('tb_products')
            .doc(widget.productId)
            .update({'status': 'pending'});

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Booking added successfully, menunggu verifikasi'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _formKey.currentState!.reset();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product not found')),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alamatController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noTelpController,
                  decoration: const InputDecoration(labelText: 'No Telp'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nomorKtpController,
                  decoration: const InputDecoration(labelText: 'Nomor KTP'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your KTP number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Upload Bukti Transfer'),
                    ),
                    const SizedBox(width: 16),
                    _buktiTransfer != null
                        ? const Text('Bukti transfer uploaded')
                        : const Text('No file chosen'),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Rekening Perusahaan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Image.asset('assets/bca-logo.jpeg', width: 50, height: 50),
                    const SizedBox(width: 16),
                    const Text('4152001293/BCA/Pedri'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Image.asset('assets/mandiri-logo.jpeg', width: 50, height: 50),
                    const SizedBox(width: 16),
                    const Text('8219301293/Mandiri/Pedri'),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    bool confirm = await _showConfirmationDialog(
                        'Confirm Submission',
                        'Are you sure you want to submit the booking?');
                    if (confirm) {
                      _addBooking();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}