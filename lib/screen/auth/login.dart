import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import '/component/confirmation_dialog.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _login(
      BuildContext context, String name, String password) async {
    try {
      // Fetch user data from Firestore
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('tb_user')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw 'User tidak ditemukan';
      }

      DocumentSnapshot userDoc = userQuery.docs.first;
      String storedHashedPassword = userDoc['password'];

      // Verify the password using bcrypt
      if (!BCrypt.checkpw(password, storedHashedPassword)) {
        throw 'Password yang anda masukan salah';
      }

      // Custom authentication logic
      String uid = userDoc.id;
      String role = userDoc['role'];

      // Navigate to different routes based on role
      if (role == 'admin' || role == 'pimpinan') {
        Navigator.pushReplacementNamed(context, '/admin', arguments: {'uid': uid, 'role': role});
      } else if (role == 'pengguna') {
        Navigator.pushReplacementNamed(context, '/user', arguments: uid);
      }
    } catch (e) {
      // Handle login error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String title, String message) async {
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
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SIM Booking Rumah',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            bool confirm = await _showConfirmationDialog(
                              context,
                              'Login Confirmation',
                              'Are you sure you want to login?',
                            );
                            if (confirm) {
                              _login(context, nameController.text, passwordController.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}