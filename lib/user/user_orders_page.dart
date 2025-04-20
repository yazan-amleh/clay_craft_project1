import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/order.dart';
import 'order_details_page.dart';
import 'dart:developer' as developer;

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({super.key});

  @override
  State<UserOrdersPage> createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    developer.log('Initializing UserOrdersPage', name: 'user.orders');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    developer.log('Building UserOrdersPage', name: 'user.orders');

    if (currentUser == null) {
      developer.log('User not logged in, showing login message', name: 'user.orders');
      return Scaffold(
        backgroundColor: const Color(0xFFD1C0AB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD1C0AB),
          title: const Text(
            'طلباتي',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle,
                size: 64,
                color: Colors.white.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              const Text(
                'يجب تسجيل الدخول لعرض طلباتك',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login page
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB49C85),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFD1C0AB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1C0AB),
        title: const Text(
          'طلباتي',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'قيد الانتظار'),
            Tab(text: 'موافق عليها'),
            Tab(text: 'مرفوضة'),
          ],
        ),
      ),
      body: StreamBuilder<List<Order>>(
        stream: firestoreService.getUserOrders(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            developer.log('Waiting for user orders data...', name: 'user.orders');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            developer.log('Error loading user orders: $error', name: 'user.orders', error: error);
            return Center(
              child: Text(
                'حدث خطأ: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final allOrders = snapshot.data ?? [];
          developer.log('Loaded ${allOrders.length} orders for user', name: 'user.orders');
          
          final pendingOrders = allOrders.where((order) => order.status == OrderStatus.pending).toList();
          final approvedOrders = allOrders.where((order) => order.status == OrderStatus.approved).toList();
          final rejectedOrders = allOrders.where((order) => order.status == OrderStatus.rejected).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // Pending Orders Tab
              _buildOrdersList(
                context,
                pendingOrders,
                'قيد الانتظار',
                Colors.orange,
                Icons.hourglass_empty,
              ),
              
              // Approved Orders Tab
              _buildOrdersList(
                context,
                approvedOrders,
                'موافق عليها',
                Colors.green,
                Icons.check_circle,
              ),
              
              // Rejected Orders Tab
              _buildOrdersList(
                context,
                rejectedOrders,
                'مرفوضة',
                Colors.red,
                Icons.cancel,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    List<Order> orders,
    String statusText,
    Color statusColor,
    IconData statusIcon,
  ) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              statusIcon,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات $statusText',
              style: const TextStyle(
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
        return UserOrderCard(
          order: order,
          statusColor: statusColor,
          statusIcon: statusIcon,
          statusText: statusText,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserOrderDetailsPage(order: order),
              ),
            );
          },
        );
      },
    );
  }
}

class UserOrderCard extends StatelessWidget {
  final Order order;
  final Color statusColor;
  final IconData statusIcon;
  final String statusText;
  final VoidCallback onTap;

  const UserOrderCard({
    super.key,
    required this.order,
    required this.statusColor,
    required this.statusIcon,
    required this.statusText,
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
              // Status Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
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
              
              // Order Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'عدد المنتجات: ${order.items.length}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'المبلغ الإجمالي: ${order.totalAmount.toStringAsFixed(2)} JD',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFFB49C85),
                    ),
                  ),
                ],
              ),
              
              // Admin Note if exists
              if (order.adminNote != null && order.adminNote!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(),
                const Text(
                  'ملاحظات الإدارة:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  order.adminNote!,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: order.status == OrderStatus.rejected ? Colors.red : Colors.black87,
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              
              // View Details Button
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_ios, size: 14),
                  label: const Text('عرض التفاصيل'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB49C85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
