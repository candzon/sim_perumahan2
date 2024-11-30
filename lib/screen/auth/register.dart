import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import '/component/confirmation_dialog.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  Future<void> _register(
      BuildContext context, String name, String email, String password, String alamat, String noTelp) async {
    try {
      // Hash the password using bcrypt
      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // Generate a new document ID for the user
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('tb_user').doc();

      // Save user data in Firestore with role 'pengguna'
      await userDocRef.set({
        'name': name,
        'email': email,
        'password': hashedPassword,
        'uid': userDocRef.id,
        'alamat': alamat,
        'no_telp': noTelp,
        'role': 'pengguna',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Navigate to login screen after registration
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Handle registration error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
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
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController alamatController = TextEditingController();
    final TextEditingController noTelpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: alamatController,
                          decoration: const InputDecoration(
                            labelText: 'Alamat',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: noTelpController,
                          decoration: const InputDecoration(
                            labelText: 'No Telp',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
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
                              'Registration Confirmation',
                              'Are you sure you want to register?',
                            );
                            if (confirm) {
                              _register(
                                context,
                                nameController.text,
                                emailController.text,
                                passwordController.text,
                                alamatController.text,
                                noTelpController.text,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}