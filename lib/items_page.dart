class Item {
  final String name;
  final double price;
  final String imageUrl;
  final double? discount;

  Item({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.discount,
  });

  /// Factory constructor to create an Item from a Map (e.g., from JSON or local data).
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      name: map['name'],
      price: _parsePrice(map['price']),
      imageUrl: map['image'],
      discount:
          map.containsKey('discount') ? _parsePrice(map['discount']) : null,
    );
  }

  /// Helper method to clean and convert price strings like "12.5 JD" to a double.
  static double _parsePrice(String priceString) {
    return double.parse(
      priceString.replaceAll('JD', '').trim(),
    );
  }

  /// Converts the Item object into a Map for storage or transmission.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': '${price.toStringAsFixed(2)} JD',
      'image': imageUrl,
      if (discount != null) 'discount': '${discount!.toStringAsFixed(2)} JD',
    };
  }
}
