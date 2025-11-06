import 'package:flutter/foundation.dart'; // ✅ Needed for ChangeNotifier

// ✅ Part 1: The CartItem Model
class CartItem {
  final String id; // Unique product ID
  final String name;
  final double price;
  int quantity; // Quantity can change

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1, // Default to 1 when added
  });
}

// ✅ Part 2: The CartProvider Class
class CartProvider with ChangeNotifier {
  // Private list of items in the cart
  final List<CartItem> _items = [];

  // Public getter to access items (read-only)
  List<CartItem> get items => _items;

  // Getter to calculate total number of items
  int get itemCount {
    int total = 0;
    for (var item in _items) {
      total += item.quantity;
    }
    return total;
  }

  // Getter to calculate total price
  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  // Add item to cart
  void addItem(String id, String name, double price) {
    var index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
      // If item exists, increase quantity
      _items[index].quantity++;
    } else {
      // If not, add new item
      _items.add(CartItem(id: id, name: name, price: price));
    }

    // Notify listeners that data changed
    notifyListeners();
  }

  // Remove item from cart
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
