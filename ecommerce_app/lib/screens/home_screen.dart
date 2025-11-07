import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce_app/screens/admin_panel_screen.dart';
import 'package:ecommerce_app/widgets/product_card.dart';
import 'package:ecommerce_app/screens/product_detail_screen.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/cart_screen.dart';
import 'package:ecommerce_app/screens/order_history_screen.dart'; // ✅ ADD THIS
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userRole = 'user';
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    if (_currentUser == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final role = userDoc.data()!['role'] ?? 'user';
        print('🧩 User role fetched: $role');
        setState(() {
          _userRole = role;
        });
      } else {
        print('⚠️ No user doc found for ${_currentUser!.uid}');
      }
    } catch (e) {
      print('❌ Error fetching user role: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Sign-out error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentUser != null ? 'Welcome, ${_currentUser!.email}' : 'Home',
        ),
        actions: [
          // ✅ Cart Icon with Badge
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Badge(
                label: Text(cart.itemCount.toString()),
                isLabelVisible: cart.itemCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'View Cart',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // ✅ New Order History Button
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),

          if (_userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _signOut,
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No products found. Add some in the Admin Panel!'),
            );
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 4,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productDoc = products[index];
              final productData = productDoc.data() as Map<String, dynamic>;

              return ProductCard(
                productName: productData['name'] ?? 'No Name',
                price: (productData['price'] ?? 0).toDouble(),
                imageUrl: productData['imageUrl'] ?? '',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        productData: productData,
                        productId: productDoc.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
