import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _editNameController = TextEditingController();
  final _editEmailController = TextEditingController();
  final _editPasswordController = TextEditingController();
  String? _selectedRole;
  String? _editSelectedRole;

  void _addUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final hashedPassword = BCrypt.hashpw(_passwordController.text, BCrypt.gensalt());

        await FirebaseFirestore.instance
            .collection('tb_user')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'name': _nameController.text,
          'email': _emailController.text,
          'alamat': 'NULL',
          'no_telp': 'NULL',
          'password': hashedPassword,
          'role': _selectedRole,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User added successfully')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedRole = null;
        });
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add user: ${e.message}')),
        );
      }
    }
  }

  void _editUser(String id, Map<String, dynamic> data) async {
    _editNameController.text = data['name'];
    _editEmailController.text = data['email'];
    _editSelectedRole = data['role'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Form(
            key: _editFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _editNameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _editEmailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _editPasswordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _editSelectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: ['admin', 'pengguna', 'pimpinan']
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _editSelectedRole = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
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
                  final updateData = {
                    'name': _editNameController.text,
                    'email': _editEmailController.text,
                    'role': _editSelectedRole,
                    'updated_at': FieldValue.serverTimestamp(),
                  };
                  if (_editPasswordController.text.isNotEmpty) {
                    updateData['password'] = BCrypt.hashpw(_editPasswordController.text, BCrypt.gensalt());
                  }
                  await FirebaseFirestore.instance.collection('tb_user').doc(id).update(updateData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User updated successfully')),
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

  void _deleteUser(String id) async {
    try {
      await FirebaseFirestore.instance.collection('tb_user').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
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
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: ['admin', 'pengguna', 'pimpinan']
                        .map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a role';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addUser,
                    child: const Text('Tambah User'),
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
                    stream: FirebaseFirestore.instance.collection('tb_user').orderBy('created_at', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final users = snapshot.data!.docs;

                      return DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Role')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: users.map((user) {
                          return DataRow(cells: [
                            DataCell(Text(user['name'])),
                            DataCell(Text(user['email'])),
                            DataCell(Text(user['role'])),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editUser(user.id, user.data() as Map<String, dynamic>),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteUser(user.id),
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