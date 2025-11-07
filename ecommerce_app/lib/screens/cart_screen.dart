import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/order_success_screen.dart'; // ✅ Added
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ Converted to StatefulWidget
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ✅ Loading state for the Place Order button
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          // List of items or empty message
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final cartItem = cart.items[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(cartItem.name[0]),
                  ),
                  title: Text(cartItem.name),
                  subtitle: Text('Qty: ${cartItem.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₱${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          cart.removeItem(cartItem.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Total price summary card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₱${cart.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Place Order Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: (_isLoading || cart.items.isEmpty)
                  ? null
                  : () async {
                setState(() {
                  _isLoading = true;
                });

                try {
                  final cartProvider =
                  Provider.of<CartProvider>(context, listen: false);

                  // Place order and clear cart
                  await cartProvider.placeOrder();
                  await cartProvider.clearCart();

                  // Navigate to success screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>
                        const OrderSuccessScreen()),
                        (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to place order: $e')),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }
}
