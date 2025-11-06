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

    // ✅ Listen for real-time authentication state changes
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

  // 🔹 Fetch user role from Firestore
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

    // 🚪 Not logged in → LoginScreen
    if (_user == null) {
      return const LoginScreen();
    }

    // 👑 If admin → AdminPanel
    if (_role == 'admin') {
      // 🧭 Instruction:
      // 1️⃣ Log in as your 'admin' account.
      // 2️⃣ You will see the HomeScreen, and the "Admin Panel" icon will be visible in the AppBar.
      // 3️⃣ Tap the icon to navigate to the Admin Panel where you can add products.
      return const AdminPanelScreen();
    }

    // 👤 Otherwise → Normal user
    // 🧭 Instruction:
    // 1️⃣ Log in as a normal 'user' account.
    // 2️⃣ You will see the HomeScreen, but the "Admin Panel" icon in the AppBar will be hidden.
    // 3️⃣ Log out anytime using the logout button on the AppBar.
    return const HomeScreen();
  }
}
