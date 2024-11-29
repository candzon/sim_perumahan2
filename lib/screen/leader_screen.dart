import 'package:flutter/material.dart';

class LeaderScreen extends StatelessWidget {
  const LeaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leader Dashboard')),
      body: const Center(
        child: Text('Welcome, Leader!'),
      ),
    );
  }
}