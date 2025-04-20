import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/order.dart';
import 'pending_orders_page.dart';
import 'approved_orders_page.dart';
import 'rejected_orders_page.dart';
import 'dart:developer' as developer;

class OrdersManagementPage extends StatelessWidget {
  const OrdersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    developer.log('Building OrdersManagementPage', name: 'admin.orders_management');

    return Scaffold(
      backgroundColor: const Color(0xFFD1C0AB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1C0AB),
        title: const Text(
          'إدارة الطلبات',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Orders Summary Cards
            Expanded(
              child: StreamBuilder<List<Order>>(
                stream: firestoreService.getAllOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    developer.log('Waiting for orders data...', name: 'admin.orders_management');
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    final error = snapshot.error;
                    developer.log('Error loading all orders: $error', name: 'admin.orders_management', error: error);
                    return Center(
                      child: Text(
                        'حدث خطأ: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final allOrders = snapshot.data ?? [];
                  final pendingOrders = allOrders.where((order) => order.status == OrderStatus.pending).toList();
                  final approvedOrders = allOrders.where((order) => order.status == OrderStatus.approved).toList();
                  final rejectedOrders = allOrders.where((order) => order.status == OrderStatus.rejected).toList();
                  
                  developer.log(
                    'Loaded ${allOrders.length} total orders: ${pendingOrders.length} pending, ${approvedOrders.length} approved, ${rejectedOrders.length} rejected', 
                    name: 'admin.orders_management'
                  );

                  return Column(
                    children: [
                      // Orders Summary Title
                      const Text(
                        'ملخص الطلبات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Order Status Cards
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            // Pending Orders Card
                            _buildOrderStatusCard(
                              context: context,
                              title: 'قيد الانتظار',
                              count: pendingOrders.length,
                              icon: Icons.hourglass_empty,
                              color: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PendingOrdersPage(),
                                  ),
                                );
                              },
                            ),
                            
                            // Approved Orders Card
                            _buildOrderStatusCard(
                              context: context,
                              title: 'موافق عليها',
                              count: approvedOrders.length,
                              icon: Icons.check_circle,
                              color: Colors.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ApprovedOrdersPage(),
                                  ),
                                );
                              },
                            ),
                            
                            // Rejected Orders Card
                            _buildOrderStatusCard(
                              context: context,
                              title: 'مرفوضة',
                              count: rejectedOrders.length,
                              icon: Icons.cancel,
                              color: Colors.red,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RejectedOrdersPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Orders Section
            Expanded(
              flex: 2,
              child: StreamBuilder<List<Order>>(
                stream: firestoreService.getAllOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    developer.log('Waiting for orders data...', name: 'admin.orders_management');
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    final error = snapshot.error;
                    developer.log('Error loading all orders: $error', name: 'admin.orders_management', error: error);
                    return Center(
                      child: Text(
                        'حدث خطأ: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final orders = snapshot.data ?? [];
                  
                  // Take only the 5 most recent orders
                  final recentOrders = orders.take(5).toList();

                  if (recentOrders.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد طلبات حديثة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أحدث الطلبات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: recentOrders.length,
                          itemBuilder: (context, index) {
                            final order = recentOrders[index];
                            return _buildRecentOrderCard(context, order);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrderCard(BuildContext context, Order order) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = 'قيد الانتظار';
        break;
      case OrderStatus.approved:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'تمت الموافقة';
        break;
      case OrderStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'مرفوض';
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.grey;
        statusIcon = Icons.block;
        statusText = 'ملغي';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            statusIcon,
            color: statusColor,
          ),
        ),
        title: Text(
          'طلب #${order.id.substring(0, 8)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('العميل: ${order.userName}'),
            Text(
              'المبلغ: ${order.totalAmount.toStringAsFixed(2)} JD',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatDate(order.orderDate),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to order details based on status
          switch (order.status) {
            case OrderStatus.pending:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PendingOrdersPage(),
                ),
              );
              break;
            case OrderStatus.approved:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ApprovedOrdersPage(),
                ),
              );
              break;
            case OrderStatus.rejected:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RejectedOrdersPage(),
                ),
              );
              break;
            case OrderStatus.cancelled:
              // Handle cancelled orders if needed
              break;
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
