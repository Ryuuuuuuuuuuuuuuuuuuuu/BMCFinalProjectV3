import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/widgets/order_card.dart'; // ✅ Import our custom card

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get the current user
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: user == null
      // ✅ If user is not logged in
          ? const Center(
        child: Text('Please log in to see your orders.'),
      )
      // ✅ If logged in, show orders via StreamBuilder
          : StreamBuilder<QuerySnapshot>(
        // ✅ Firestore query: filter by current user's UID
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // ✅ Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ Error state
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // ✅ No orders yet
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('You have not placed any orders yet.'),
            );
          }

          // ✅ Orders data available
          final orderDocs = snapshot.data!.docs;

          // ✅ List of OrderCards
          return ListView.builder(
            itemCount: orderDocs.length,
            itemBuilder: (context, index) {
              final orderData =
              orderDocs[index].data() as Map<String, dynamic>;

              // ✅ Ensure we pass the right fields to OrderCard
              // Convert timestamp if needed inside OrderCard
              return OrderCard(orderData: orderData);
            },
          );
        },
      ),
    );
  }
}

