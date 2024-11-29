import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderScreen extends StatelessWidget {
  const LeaderScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome, Leader!'),
      ),
    );
  }
}