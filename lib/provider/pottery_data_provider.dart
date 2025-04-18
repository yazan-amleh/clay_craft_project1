import 'package:flutter/material.dart';

class PotteryItem {
  final String name;
  final double price;
  final String imageUrl;
  final String videoUrl;
  final String category;

  PotteryItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.videoUrl,
    required this.category,
  });
}

class PotteryDataProvider extends ChangeNotifier {
  final List<PotteryItem> _items = [];

  List<PotteryItem> get items => List.unmodifiable(_items);

  void addItem(PotteryItem item) {
    _items.add(item);
    notifyListeners();
  }

  List<PotteryItem> getItemsByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  void deleteItem(PotteryItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void updateItem(PotteryItem oldItem, PotteryItem newItem) {
    final index = _items.indexOf(oldItem);
    if (index != -1) {
      _items[index] = newItem;
      notifyListeners();
    }
  }
}
