import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';
import 'package:clay_craft_project/provider/pottery_data_provider.dart';
import 'dart:developer' as developer;

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String potteryCollection = 'pottery_items';

  // Add a new pottery item to Firestore
  Future<DocumentReference> addPotteryItem(PotteryItem item) async {
    try {
      // إضافة المنتج إلى Firestore وإرجاع المرجع للمستند الجديد
      final docRef = await _firestore.collection(potteryCollection).add({
        'name': item.name,
        'price': item.price,
        'imageUrl': item.imageUrl,
        'videoUrl': item.videoUrl,
        'category': item.category,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      debugPrint('تمت إضافة المنتج بنجاح بمعرف: ${docRef.id}');
      return docRef;
    } catch (e) {
      debugPrint('خطأ في إضافة المنتج: $e');
      throw e;
    }
  }

  // Get all pottery items
  Stream<List<PotteryItem>> getPotteryItems() {
    debugPrint('جاري استرجاع جميع المنتجات...');
    return _firestore
        .collection(potteryCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        debugPrint('تم استرجاع المنتج: ${data['name']} بمعرف: ${doc.id}');
        return PotteryItem(
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          videoUrl: data['videoUrl'] ?? '',
          category: data['category'] ?? '',
          documentId: doc.id,
        );
      }).toList();
      
      debugPrint('تم استرجاع ${items.length} منتج');
      return items;
    });
  }

  // الحصول على جميع المنتجات مرة واحدة (وليس كتدفق)
  Future<List<PotteryItem>> getAllPotteryItems() async {
    try {
      final snapshot = await _firestore
          .collection(potteryCollection)
          .orderBy('timestamp', descending: true)
          .get();
      
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        return PotteryItem(
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          videoUrl: data['videoUrl'] ?? '',
          category: data['category'] ?? '',
          documentId: doc.id,
        );
      }).toList();
      
      debugPrint('تم استرجاع ${items.length} منتج من Firestore');
      return items;
    } catch (e) {
      debugPrint('خطأ في استرجاع المنتجات: $e');
      throw e;
    }
  }
  
  // تحديث منتج موجود في Firestore
  Future<void> updatePotteryItem(String documentId, PotteryItem item) async {
    try {
      await _firestore.collection(potteryCollection).doc(documentId).update({
        'name': item.name,
        'price': item.price,
        'imageUrl': item.imageUrl,
        'videoUrl': item.videoUrl,
        'category': item.category,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('تم تحديث المنتج بنجاح بمعرف: $documentId');
    } catch (e) {
      debugPrint('خطأ في تحديث المنتج: $e');
      throw e;
    }
  }
  
  // حذف منتج من Firestore
  Future<void> deletePotteryItem(String documentId) async {
    try {
      await _firestore.collection(potteryCollection).doc(documentId).delete();
      
      debugPrint('تم حذف المنتج بنجاح بمعرف: $documentId');
    } catch (e) {
      debugPrint('خطأ في حذف المنتج: $e');
      throw e;
    }
  }

  // Get pottery items by category
  Stream<List<PotteryItem>> getPotteryItemsByCategory(String category) {
    debugPrint('جاري استرجاع منتجات الفئة: $category...');
    return _firestore
        .collection(potteryCollection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map((doc) {
        final data = doc.data();
        debugPrint('تم استرجاع المنتج: ${data['name']} من الفئة: $category بمعرف: ${doc.id}');
        return PotteryItem(
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          videoUrl: data['videoUrl'] ?? '',
          category: data['category'] ?? '',
          documentId: doc.id,
        );
      }).toList();
      
      debugPrint('تم استرجاع ${items.length} منتج من الفئة: $category');
      return items;
    });
  }

  // Get a single pottery item by ID
  Future<PotteryItem?> getPotteryItemById(String docId) async {
    try {
      debugPrint('جاري استرجاع المنتج بمعرف: $docId');
      final docSnapshot = await _firestore.collection(potteryCollection).doc(docId).get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        debugPrint('تم استرجاع المنتج: ${data['name']}');
        return PotteryItem(
          name: data['name'] ?? '',
          price: (data['price'] ?? 0.0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          videoUrl: data['videoUrl'] ?? '',
          category: data['category'] ?? '',
          documentId: docSnapshot.id,
        );
      } else {
        debugPrint('المنتج غير موجود');
        return null;
      }
    } catch (e) {
      debugPrint('خطأ في استرجاع المنتج: $e');
      throw e;
    }
  }

  // Order Management Methods
  
  // Add a new order to Firestore
  Future<String> addOrder(Order order) async {
    try {
      developer.log('Adding new order to Firestore', name: 'firestore.orders');
      DocumentReference docRef = await _firestore.collection('orders').add(order.toMap());
      developer.log('Order added successfully with ID: ${docRef.id}', name: 'firestore.orders');
      return docRef.id;
    } catch (e) {
      developer.log('Error adding order: $e', name: 'firestore.orders', error: e);
      throw Exception('Failed to add order: $e');
    }
  }
  
  // Get all orders
  Stream<List<Order>> getAllOrders() {
    developer.log('Getting all orders from Firestore', name: 'firestore.orders');
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          developer.log('Received ${snapshot.docs.length} orders from Firestore', name: 'firestore.orders');
          return snapshot.docs
              .map((doc) => Order.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get orders by status
  Stream<List<Order>> getOrdersByStatus(OrderStatus status) {
    String statusStr = status.toString().split('.').last;
    developer.log('Getting orders with status: $statusStr', name: 'firestore.orders');
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: statusStr)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          developer.log('Received ${snapshot.docs.length} orders with status $statusStr', name: 'firestore.orders');
          return snapshot.docs
              .map((doc) => Order.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get orders for a specific user
  Stream<List<Order>> getUserOrders(String userId) {
    developer.log('Getting orders for user: $userId', name: 'firestore.orders');
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          developer.log('Received ${snapshot.docs.length} orders for user $userId', name: 'firestore.orders');
          return snapshot.docs
              .map((doc) => Order.fromFirestore(doc))
              .toList();
        });
  }
  
  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status, {String? adminNote}) async {
    try {
      developer.log('Updating order $orderId status to ${status.toString().split('.').last}', name: 'firestore.orders');
      Map<String, dynamic> updateData = {
        'status': status.toString().split('.').last,
      };
      
      if (adminNote != null) {
        updateData['adminNote'] = adminNote;
        developer.log('Adding admin note to order $orderId', name: 'firestore.orders');
      }
      
      await _firestore.collection('orders').doc(orderId).update(updateData);
      developer.log('Order $orderId status updated successfully', name: 'firestore.orders');
    } catch (e) {
      developer.log('Error updating order status: $e', name: 'firestore.orders', error: e);
      throw Exception('Failed to update order status: $e');
    }
  }
}
