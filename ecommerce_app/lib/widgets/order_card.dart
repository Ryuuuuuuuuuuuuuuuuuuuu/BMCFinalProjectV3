import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ Import intl for DateFormat

class OrderCard extends StatelessWidget {
  // ✅ Pass in the entire order data map
  final Map<String, dynamic> orderData;

  const OrderCard({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    // ✅ Safely get the timestamp
    final Timestamp? timestamp = orderData['createdAt'];
    final String formattedDate;

    if (timestamp != null) {
      // ✅ Format timestamp to readable date
      formattedDate = DateFormat('MM/dd/yyyy - hh:mm a')
          .format(timestamp.toDate());
    } else {
      formattedDate = 'Date not available';
    }

    // ✅ Use a Card for nice UI
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListTile(
          // ✅ Title: Total Price
          title: Text(
            'Total: ₱${(orderData['totalPrice'] as double).toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          // ✅ Subtitle: Item count and Status
          subtitle: Text(
            'Items: ${orderData['itemCount']}\n'
                'Status: ${orderData['status']}',
          ),

          // ✅ Trailing: Formatted date
          trailing: Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),

          // ✅ Allow subtitle to have 2 lines
          isThreeLine: true,
        ),
      ),
    );
  }
}
