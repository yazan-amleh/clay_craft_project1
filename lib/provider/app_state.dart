import 'package:clay_craft_project/fifth_admin.dart';
import 'package:flutter/material.dart';
import '../items_page.dart';

class AppState with ChangeNotifier {
  final List<Item> _favorites = [];
  final List<Item> _shoppingList = [];

  // Getter for favorite items
  List<Item> get favoriteItems => _favorites;

  // Getter for shopping items
  List<Item> get shoppingItems => _shoppingList;

  // Check if an item is in the favorites list
  bool isFavorite(Item item) {
    return _favorites.contains(item);
  }

  // Toggle an item's favorite status
  void toggleFavorite(Item item) {
    if (isFavorite(item)) {
      _favorites.remove(item);
    } else {
      _favorites.add(item);
    }
    notifyListeners();
  }

  // Check if an item is in the shopping list
  bool isInShoppingList(Item item) {
    return _shoppingList.contains(item);
  }

  // Toggle an item's shopping list status
  void toggleShopping(Item item) {
    if (isInShoppingList(item)) {
      _shoppingList.remove(item);
    } else {
      _shoppingList.add(item);
    }
    notifyListeners();
  }

  getPotteryByCategory(String s) {}

  void addPotteryItem(potteryItem) {}

  getItemsByCategory(String s) {}

  void addItem(PotteryItem newItem) {}
}
