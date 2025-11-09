import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/home_screen.dart';
import 'package:ecommerce_app/screens/admin_panel_screen.dart';
import 'package:ecommerce_app/screens/login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _user;
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();


    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        setState(() {
          _user = null;
          _role = null;
          _loading = false;
        });
      } else {
        _user = user;
        await _fetchUserRole(user);
      }
    });
  }

  Future<void> _fetchUserRole(User user) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _role = userDoc.data()?['role'] ?? 'user';
        _loading = false;
      });
    } catch (e) {
      print("Error getting user role: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }


    if (_user == null) {
      return const LoginScreen();
    }

    if (_role == 'admin') {
      return const AdminPanelScreen();
    }

    return const HomeScreen();
  }
}
