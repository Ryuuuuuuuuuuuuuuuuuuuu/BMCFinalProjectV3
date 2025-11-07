import 'dart:async'; // ✅ For StreamSubscription
import 'package:flutter/foundation.dart'; // ✅ Needed for ChangeNotifier
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Firestore

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

  // Convert CartItem to Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // Create CartItem from Map fetched from Firestore
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }
}

// ✅ Part 2: The CartProvider Class
class CartProvider with ChangeNotifier {
  // Private list of items in the cart
  List<CartItem> _items = []; // removed final

  // Firebase properties
  String? _userId; // Current user's ID
  StreamSubscription? _authSubscription; // Auth listener
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // ✅ Constructor: Listen to auth changes
  CartProvider() {
    print('CartProvider initialized');
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // User logged out
        print('User logged out, clearing cart.');
        _userId = null;
        _items = [];
      } else {
        // User logged in
        print('User logged in: ${user.uid}. Fetching cart...');
        _userId = user.uid;
        _fetchCart(); // Load saved cart from Firestore
      }
      notifyListeners(); // Update UI
    });
  }

  // Add item to cart
  void addItem(String id, String name, double price) {
    var index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(id: id, name: name, price: price));
    }

    _saveCart(); // Save to Firestore
    notifyListeners();
  }

  // Remove item from cart
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart(); // Save to Firestore
    notifyListeners();
  }

  // ✅ Fetch cart from Firestore
  Future<void> _fetchCart() async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();

      if (doc.exists && doc.data()!['cartItems'] != null) {
        final List<dynamic> cartData = doc.data()!['cartItems'];
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
        print('Cart fetched successfully: ${_items.length} items');
      } else {
        _items = [];
      }
    } catch (e) {
      print('Error fetching cart: $e');
      _items = [];
    }
    notifyListeners();
  }

  // ✅ Save cart to Firestore
  Future<void> _saveCart() async {
    if (_userId == null) return;

    try {
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();

      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });
      print('Cart saved to Firestore');
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // ✅ Place order
  Future<void> placeOrder() async {
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user is not logged in.');
    }

    try {
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();

      final double total = totalPrice;
      final int count = itemCount;

      await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData,
        'totalPrice': total,
        'itemCount': count,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('Error placing order: $e');
      throw e;
    }
  }

  // ✅ Clear cart locally and in Firestore
  Future<void> clearCart() async {
    _items = [];

    if (_userId != null) {
      try {
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        print('Firestore cart cleared.');
      } catch (e) {
        print('Error clearing Firestore cart: $e');
      }
    }

    notifyListeners();
  }

  // Cancel auth listener when provider is disposed
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
