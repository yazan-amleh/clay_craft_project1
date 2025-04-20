import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/firestore_service.dart';
import 'dart:developer' as developer;

class OrderDetailPage extends StatefulWidget {
  final Order order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final TextEditingController _noteController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.order.adminNote ?? '';
    developer.log('Initializing OrderDetailPage for order ${widget.order.id}', name: 'admin.order_detail');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    developer.log('Building OrderDetailPage for order ${widget.order.id}', name: 'admin.order_detail');
    
    return Scaffold(
      backgroundColor: const Color(0xFFD1C0AB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1C0AB),
        title: Text(
          'تفاصيل الطلب #${widget.order.id.substring(0, 8)}',
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
            
            // Customer Information
            _buildSectionCard(
              title: 'معلومات العميل',
              icon: Icons.person,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('الاسم', widget.order.userName),
                  const SizedBox(height: 8),
                  _buildInfoRow('البريد الإلكتروني', widget.order.userEmail),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Order Items
            _buildSectionCard(
              title: 'المنتجات',
              icon: Icons.shopping_bag,
              child: Column(
                children: [
                  ...widget.order.items.map((item) => _buildOrderItemCard(item)),
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
                          '${widget.order.totalAmount.toStringAsFixed(2)} JD',
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
            
            const SizedBox(height: 16),
            
            // Admin Note
            _buildSectionCard(
              title: 'ملاحظات الإدارة',
              icon: Icons.note,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'أضف ملاحظة للطلب...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            if (widget.order.status == OrderStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _updateOrderStatus(
                                context,
                                firestoreService,
                                OrderStatus.approved,
                              ),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('موافقة على الطلب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : () => _updateOrderStatus(
                                context,
                                firestoreService,
                                OrderStatus.rejected,
                              ),
                      icon: const Icon(Icons.cancel),
                      label: const Text('رفض الطلب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
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

    switch (widget.order.status) {
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
            Icon(
              statusIcon,
              color: statusColor,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حالة الطلب',
                    style: TextStyle(
                      color: Colors.grey[600],
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'تاريخ الطلب',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatDate(widget.order.orderDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
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
                  icon,
                  color: const Color(0xFFB49C85),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
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

  Future<void> _updateOrderStatus(
    BuildContext context,
    FirestoreService firestoreService,
    OrderStatus newStatus,
  ) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      developer.log(
        'Updating order ${widget.order.id} status to ${newStatus.toString().split('.').last}',
        name: 'admin.order_detail'
      );
      
      await firestoreService.updateOrderStatus(
        widget.order.id,
        newStatus,
        adminNote: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == OrderStatus.approved
                  ? 'تمت الموافقة على الطلب بنجاح'
                  : 'تم رفض الطلب',
            ),
            backgroundColor:
                newStatus == OrderStatus.approved ? Colors.green : Colors.red,
          ),
        );
        developer.log(
          'Successfully updated order ${widget.order.id} status',
          name: 'admin.order_detail'
        );
        Navigator.pop(context);
      }
    } catch (e) {
      developer.log(
        'Error updating order ${widget.order.id} status: $e',
        name: 'admin.order_detail',
        error: e
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
