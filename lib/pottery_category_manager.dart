import 'items_page.dart';

class PotteryCategoryManager {
  static final PotteryCategoryManager _instance =
      PotteryCategoryManager._internal();

  factory PotteryCategoryManager() {
    return _instance;
  }

  PotteryCategoryManager._internal();

  final Map<String, List<Item>> _categories = {
    'Functional Pottery': [],
    'Decorative Pottery': [],
    'Tableware Pottery': [],
    'Kitchenware Pottery': [],
  };

  void addItemToCategory(String category, Item item) {
    if (_categories.containsKey(category)) {
      _categories[category]!.add(item);
    }
  }

  List<Item> getItemsForCategory(String category) {
    return _categories[category] ?? [];
  }
}
