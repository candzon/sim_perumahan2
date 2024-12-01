import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screen/auth/login.dart';
import 'screen/auth/register.dart';
import 'screen/admin_screen.dart';
import 'screen/user_screen.dart';
import 'screen/leader_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIM Booking Rumah',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/admin': (context) {
          final Map<String, String> arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return AdminScreen(arguments: arguments);
        },
        '/user': (context) {
          final String uid =
          ModalRoute.of(context)!.settings.arguments as String;
          return UserScreen(uid: uid);
        },
        '/leader': (context) => const LeaderScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}