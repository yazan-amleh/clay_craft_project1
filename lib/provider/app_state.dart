import 'package:flutter/material.dart';
import '../items_page.dart';
import 'pottery_data_provider.dart';

class AppState with ChangeNotifier {
  final List<Item> _favorites = [];
  final List<Item> _shoppingList = [];

  // Getter for favorite items
  List<Item> get favoriteItems => _favorites;

  // Getter for shopping items
  List<Item> get shoppingItems => _shoppingList;

  // Check if an item is in the favorites list
  bool isFavorite(Item item) {
    return _favorites.any((i) => i.name == item.name && i.imageUrl == item.imageUrl);
  }

  // Add an item to favorites
  void addToFavorites(Item item) {
    if (!isFavorite(item)) {
      final newItem = Item(
        name: item.name,
        price: item.price,
        imageUrl: item.imageUrl,
        discount: item.discount,
        quantity: item.quantity,
      );
      _favorites.add(newItem);
      notifyListeners();
    }
  }

  // Remove an item from favorites
  void removeFromFavorites(Item item) {
    _favorites.removeWhere(
      (i) => i.name == item.name && i.imageUrl == item.imageUrl,
    );
    notifyListeners();
  }

  // Toggle an item's favorite status (legacy method, kept for compatibility)
  void toggleFavorite(Item item) {
    if (isFavorite(item)) {
      removeFromFavorites(item);
    } else {
      addToFavorites(item);
    }
  }

  // Check if an item is in the shopping list
  bool isInShoppingList(Item item) {
    return _shoppingList.any((i) => i.name == item.name && i.imageUrl == item.imageUrl);
  }

  // Add an item to the shopping list
  void addToShoppingList(Item item) {
    // Check if the item is already in the shopping list
    if (isInShoppingList(item)) {
      // If it is, find the item and increment its quantity
      final existingItem = _shoppingList.firstWhere(
        (i) => i.name == item.name && i.imageUrl == item.imageUrl,
      );
      existingItem.quantity += 1;
    } else {
      // If it's not, add it to the shopping list with quantity 1
      final newItem = Item(
        name: item.name,
        price: item.price,
        imageUrl: item.imageUrl,
        discount: item.discount,
        quantity: 1,
      );
      _shoppingList.add(newItem);
    }
    notifyListeners();
  }

  // Remove an item from the shopping list
  void removeFromShoppingList(Item item) {
    _shoppingList.removeWhere(
      (i) => i.name == item.name && i.imageUrl == item.imageUrl,
    );
    notifyListeners();
  }

  // Increment the quantity of an item in the shopping list
  void incrementQuantity(Item item) {
    if (isInShoppingList(item)) {
      final existingItem = _shoppingList.firstWhere(
        (i) => i.name == item.name && i.imageUrl == item.imageUrl,
      );
      existingItem.quantity += 1;
      notifyListeners();
    }
  }

  // Decrement the quantity of an item in the shopping list
  void decrementQuantity(Item item) {
    if (isInShoppingList(item)) {
      final existingItem = _shoppingList.firstWhere(
        (i) => i.name == item.name && i.imageUrl == item.imageUrl,
      );
      if (existingItem.quantity > 1) {
        existingItem.quantity -= 1;
      } else {
        // If quantity becomes 0, remove the item from the shopping list
        _shoppingList.remove(existingItem);
      }
      notifyListeners();
    }
  }

  // Toggle an item's shopping list status (legacy method, kept for compatibility)
  void toggleShopping(Item item) {
    if (isInShoppingList(item)) {
      removeFromShoppingList(item);
    } else {
      addToShoppingList(item);
    }
  }

  // Calculate the total price of items in the shopping list
  double get totalPrice {
    return _shoppingList.fold(0, (total, item) {
      final itemPrice = item.discount ?? item.price;
      return total + (itemPrice * item.quantity);
    });
  }

  // Clear all items from the shopping list
  void clearShoppingList() {
    _shoppingList.clear();
    notifyListeners();
  }

  getPotteryByCategory(String s) {}

  void addPotteryItem(PotteryItem potteryItem) {}

  getItemsByCategory(String s) {}

  void addItem(PotteryItem newItem) {}
}
