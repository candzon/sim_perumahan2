import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class AdminBookingList extends StatelessWidget {
  final String? role;

  const AdminBookingList({super.key, required this.role});

  Future<void> _updateStatus(String bookingId, String productId, String newStatus) async {
    // Update status in tb_booking
    await FirebaseFirestore.instance.collection('tb_booking').doc(bookingId).update({'status': newStatus});

    // Update status in tb_products
    String productStatus = newStatus == 'cancelled' ? 'available' : newStatus;
    await FirebaseFirestore.instance.collection('tb_products').doc(productId).update({'status': productStatus});
  }

  Future<Map<String, dynamic>?> _getUserDetails(String uid) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('tb_user').doc(uid).get();
    if (userSnapshot.exists) {
      return userSnapshot.data() as Map<String, dynamic>?;
    }
    return null;
  }

  void _showEnlargedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(imageUrl)),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tb_booking').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = snapshot.data!.docs;

        if (bookings.isEmpty) {
          return const Center(child: Text('No bookings found'));
        }

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            final productId = booking['product_id'];
            final uid = booking['uid'];
            final photoUrl = booking['image'];
            String currentStatus = booking['status'];

            return FutureBuilder<Map<String, dynamic>?>(
              future: _getUserDetails(uid),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userDetails = userSnapshot.data;
                final userName = userDetails?['name'] ?? 'Unknown User';

                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.all(12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        if (photoUrl != null && photoUrl.isNotEmpty) {
                          _showEnlargedImage(context, photoUrl);
                        }
                      },
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: photoUrl != null && photoUrl.isNotEmpty
                            ? Image.file(File(photoUrl), fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported),
                      ),
                    ),
                    title: Text('Booking ID: ${booking.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User: $userName'),
                        Text('Status: $currentStatus'),
                        Text('Price: Rp ${booking['price']}'),
                      ],
                    ),
                    trailing: role == 'admin'
                        ? DropdownButton<String>(
                      value: currentStatus,
                      items: <String>['pending', 'booked', 'cancelled']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _updateStatus(booking.id, productId, newValue);
                        }
                      },
                    )
                        : null,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}