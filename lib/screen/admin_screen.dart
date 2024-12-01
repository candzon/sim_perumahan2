import 'package:flutter/material.dart';
import 'package:sim_perumahan2/screen/list_booking_pelanggan.dart';
import 'add_product_screen.dart';
import 'add_user_screen.dart';
import '../component/confirmation_dialog.dart';

class AdminScreen extends StatefulWidget {
  final Map<String, String> arguments;

  const AdminScreen({super.key, required this.arguments});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Print the role to debug
    // print('User role: ${widget.arguments['role']}');
    _pages = [
      AddProductScreen(role: widget.arguments['role']!),
      AddUserScreen(role: widget.arguments['role']!),
      AdminBookingList(role: widget.arguments['role']!),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: title,
          message: message,
          onConfirm: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        );
      },
    ) ??
        false;
  }

  void _logout() async {
    bool confirm = await _showConfirmationDialog(
        'Logout', 'Are you sure you want to logout?');
    if (confirm) {
      Navigator.pushReplacementNamed(context, '/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.arguments['role'] == 'admin' ? const Text('Admin Dashboard') : const Text('Pimpinan Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Tambah Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Tambah User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List Booking',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}