import 'package:cloud_firestore/cloud_firestore.dart';
import '../items_page.dart';

enum OrderStatus {
  pending,    // قيد الانتظار
  approved,   // تمت الموافقة
  rejected,   // مرفوض
  cancelled   // ملغي
}

class Order {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final List<Item> items;
  final double totalAmount;
  final DateTime orderDate;
  OrderStatus status;
  String? adminNote;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = OrderStatus.pending,
    this.adminNote,
  });

  // Convert Order to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status.toString().split('.').last,
      'adminNote': adminNote,
    };
  }

  // Create an Order from a Firestore document
  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Parse items
    List<Item> orderItems = [];
    if (data['items'] != null) {
      for (var itemData in data['items']) {
        orderItems.add(Item.fromMap(itemData));
      }
    }

    // Parse order status
    OrderStatus orderStatus = OrderStatus.pending;
    if (data['status'] != null) {
      String statusStr = data['status'];
      orderStatus = OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusStr,
        orElse: () => OrderStatus.pending,
      );
    }

    // Parse order date
    DateTime date = DateTime.now();
    if (data['orderDate'] != null) {
      Timestamp timestamp = data['orderDate'] as Timestamp;
      date = timestamp.toDate();
    }

    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      items: orderItems,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      orderDate: date,
      status: orderStatus,
      adminNote: data['adminNote'],
    );
  }
}
