import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/app_state.dart';
import 'shopping_item_card.dart';
import 'fifth_page.dart';
import 'services/firestore_service.dart';
import 'models/order.dart';
import 'services/auth_service.dart';
import 'checkout_success_page.dart';
import 'items_page.dart';
import 'dart:developer' as developer;

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  bool _isProcessingOrder = false;

  @override
  void initState() {
    super.initState();
    developer.log('Initializing ShoppingPage', name: 'shopping.cart');
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final shoppingItems = appState.shoppingItems;
    final totalPrice = appState.totalPrice;
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);

    developer.log('Building ShoppingPage with ${shoppingItems.length} items, total: $totalPrice', name: 'shopping.cart');

    return Scaffold(
      backgroundColor: const Color(0xFFD1C0AB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1C0AB),
        title: const Text(
          'سلة التسوق',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Shopping Items List
          Expanded(
            child: shoppingItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'سلة التسوق فارغة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.shopping_bag),
                          label: const Text('تسوق الآن'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFB49C85),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FifthPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: shoppingItems.length,
                    itemBuilder: (context, index) => ShoppingItemCard(
                      item: shoppingItems[index],
                    ),
                  ),
          ),
          
          // Order Summary
          if (shoppingItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Order Summary Title
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, color: Color(0xFFB49C85)),
                      SizedBox(width: 8),
                      Text(
                        'ملخص الطلب',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Total Items and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المجموع (${shoppingItems.length} منتجات)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${totalPrice.toStringAsFixed(2)} JD',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB49C85),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Checkout Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB49C85),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isProcessingOrder
                        ? null
                        : () => _processOrder(
                              context,
                              appState,
                              firestoreService,
                              authService,
                              shoppingItems,
                              totalPrice,
                            ),
                    child: _isProcessingOrder
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'إتمام الشراء',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _processOrder(
    BuildContext context,
    AppState appState,
    FirestoreService firestoreService,
    AuthService authService,
    List<dynamic> items,
    double totalAmount,
  ) async {
    // Check if user is logged in
    if (authService.currentUser == null) {
      developer.log('Checkout failed: User not logged in', name: 'shopping.cart');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تسجيل الدخول لإتمام عملية الشراء'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingOrder = true;
    });

    developer.log('Processing order with ${items.length} items, total: $totalAmount', name: 'shopping.cart');

    try {
      // Create a new order
      final user = authService.currentUser!;
      developer.log('Creating order for user: ${user.uid}', name: 'shopping.cart');
      
      final order = Order(
        id: '', // Will be set by Firestore
        userId: user.uid,
        userName: user.displayName ?? 'مستخدم',
        userEmail: user.email ?? 'لا يوجد بريد إلكتروني',
        items: List<Item>.from(items),
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        status: OrderStatus.pending,
      );

      // Add order to Firestore
      final orderId = await firestoreService.addOrder(order);
      developer.log('Order created successfully with ID: $orderId', name: 'shopping.cart');

      if (mounted) {
        // Clear shopping cart
        appState.clearShoppingList();
        developer.log('Shopping cart cleared after successful order', name: 'shopping.cart');

        // Navigate to success page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutSuccessPage(orderId: orderId),
          ),
        );
      }
    } catch (e) {
      developer.log('Error creating order: $e', name: 'shopping.cart', error: e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessingOrder = false;
        });
      }
    }
  }
}
