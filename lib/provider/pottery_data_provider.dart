import 'package:flutter/material.dart';
import 'package:clay_craft_project/services/firestore_service.dart';

class PotteryItem {
  final String name;
  final double price;
  final String imageUrl;
  final String videoUrl;
  final String category;
  final String? documentId;
  final String? externalLink;

  PotteryItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.videoUrl,
    required this.category,
    this.documentId,
    this.externalLink,
  });
}

class PotteryDataProvider extends ChangeNotifier {
  final List<PotteryItem> _items = [];
  final FirestoreService _firestoreService = FirestoreService();
  List<PotteryItem> _firestoreItems = [];

  List<PotteryItem> get items => List.unmodifiable(_firestoreItems.isEmpty ? _items : _firestoreItems);

  PotteryDataProvider() {
    // Listen to Firestore updates
    _firestoreService.getPotteryItems().listen((items) {
      _firestoreItems = items;
      notifyListeners();
    });
  }

  void addItem(PotteryItem item) async {
    // Add to Firestore
    await _firestoreService.addPotteryItem(item);
    // Local update is handled by the Firestore listener
  }

  List<PotteryItem> getItemsByCategory(String category) {
    return items.where((item) => item.category == category).toList();
  }

  void deleteItem(String documentId) async {
    if (documentId.isNotEmpty) {
      try {
        await _firestoreService.deletePotteryItem(documentId);
        // Update will happen via Firestore listener
      } catch (e) {
        print('Error deleting item: $e');
      }
    }
  }

  void updateItem(PotteryItem oldItem, PotteryItem newItem) {
    // This would need document ID from Firestore
    // For now, we'll just update the local list
    final index = _items.indexOf(oldItem);
    if (index != -1) {
      _items[index] = newItem;
      notifyListeners();
    }
  }
}
