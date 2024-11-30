import 'package:cloud_firestore/cloud_firestore.dart';


class House {
  final String id;
  final String image;
  final String location;
  final String type;
  final String houseType;
  final String status;
  final String price;

  House({
    required this.id,
    required this.image,
    required this.location,
    required this.type,
    required this.houseType,
    required this.status,
    required this.price,
  });

  factory House.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return House(
      id: doc.id,
      image: data['image'] ?? '',
      location: data['location'] ?? 'N/A',
      type: data['type'] ?? 'N/A',
      houseType: data['houseType'] ?? 'N/A',
      status: data['status'] ?? 'available',
      price: data['price'] ?? 0,
    );
  }
}