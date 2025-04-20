import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/firestore_service.dart';
import 'order_detail_page.dart';
import 'dart:developer' as developer;

class PendingOrdersPage extends StatelessWidget {
  const PendingOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    developer.log('Building PendingOrdersPage', name: 'admin.pending_orders');

    return Scaffold(
      backgroundColor: const Color(0xFFD1C0AB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1C0AB),
        title: const Text(
          'الطلبات قيد الانتظار',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Order>>(
        stream: firestoreService.getOrdersByStatus(OrderStatus.pending),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            developer.log('Waiting for data...', name: 'admin.pending_orders');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            developer.log('Error loading pending orders: $error', name: 'admin.pending_orders', error: error);
            return Center(
              child: Text(
                'حدث خطأ: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final orders = snapshot.data ?? [];
          developer.log('Loaded ${orders.length} pending orders', name: 'admin.pending_orders');

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    size: 64,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد طلبات قيد الانتظار',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(
                order: order,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailPage(order: order),
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

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'طلب #${order.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(order.orderDate),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Divider(),
              
              // Customer Info
              Text(
                'العميل: ${order.userName}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'البريد الإلكتروني: ${order.userEmail}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              
              // Order Summary
              Text(
                'عدد المنتجات: ${order.items.length}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'المبلغ الإجمالي: ${order.totalAmount.toStringAsFixed(2)} JD',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFB49C85),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // View Details Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility),
                    label: const Text('عرض التفاصيل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB49C85),
                      side: const BorderSide(color: Color(0xFFB49C85)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
