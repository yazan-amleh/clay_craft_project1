import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/order.dart';
import 'dart:developer' as developer;

class UserOrderDetailsPage extends StatelessWidget {
  final Order order;

  const UserOrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    developer.log('Building UserOrderDetailsPage for order ${order.id}', name: 'user.order_details');
    
    return Scaffold(
      backgroundColor: const Color(0xFFD1C0AB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1C0AB),
        title: Text(
          'تفاصيل الطلب #${order.id.substring(0, 8)}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            _buildStatusCard(),
            
            const SizedBox(height: 16),
            
            // Order ID Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFB49C85),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'معلومات الطلب',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'رقم الطلب:',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              order.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.copy,
                                size: 16,
                                color: Color(0xFFB49C85),
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: order.id));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم نسخ رقم الطلب'),
                                    backgroundColor: Color(0xFFB49C85),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'تاريخ الطلب:',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _formatDate(order.orderDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Order Items
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          color: Color(0xFFB49C85),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'المنتجات',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    ...order.items.map((item) => _buildOrderItemCard(item)),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'المجموع',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${order.totalAmount.toStringAsFixed(2)} JD',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFB49C85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Admin Note if exists
            if (order.adminNote != null && order.adminNote!.isNotEmpty)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            order.status == OrderStatus.rejected
                                ? Icons.cancel
                                : Icons.note,
                            color: order.status == OrderStatus.rejected
                                ? Colors.red
                                : const Color(0xFFB49C85),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            order.status == OrderStatus.rejected
                                ? 'سبب الرفض'
                                : 'ملاحظات الإدارة',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Text(
                        order.adminNote!,
                        style: TextStyle(
                          fontSize: 16,
                          color: order.status == OrderStatus.rejected
                              ? Colors.red
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Help Text
            if (order.status == OrderStatus.pending)
              const Card(
                elevation: 1,
                color: Color(0xFFF5F5F5),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.blue,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'طلبك قيد المراجعة من قبل الإدارة. سيتم إعلامك عند تغيير حالة الطلب.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        statusText = 'قيد الانتظار';
        statusIcon = Icons.hourglass_empty;
        break;
      case OrderStatus.approved:
        statusColor = Colors.green;
        statusText = 'تمت الموافقة';
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.rejected:
        statusColor = Colors.red;
        statusText = 'مرفوض';
        statusIcon = Icons.cancel;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.grey;
        statusText = 'ملغي';
        statusIcon = Icons.block;
        break;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حالة الطلب',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(item) {
    final bool hasDiscount = item.discount != null;
    final double displayPrice = hasDiscount ? item.discount! : item.price;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        "${item.price.toStringAsFixed(2)} JD",
                        style: const TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      "${displayPrice.toStringAsFixed(2)} JD",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: hasDiscount ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Quantity and Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "الكمية: ${item.quantity}",
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                "المجموع: ${(displayPrice * item.quantity).toStringAsFixed(2)} JD",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
