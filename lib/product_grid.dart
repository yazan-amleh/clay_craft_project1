import 'package:flutter/material.dart';
import 'app_images.dart';
import 'items_page.dart';
import 'item_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});
  static List<Item> allItems = [
    Item(name: "White Plates", price: 10.00, imageUrl: Assets.imagesF1),
    Item(name: "Brown Plates", price: 8.50, imageUrl: Assets.imagesF2),
    Item(name: "Teapots Plates", price: 15.00, imageUrl: Assets.imagesF3),
    Item(name: "Blue Teapots", price: 11.00, imageUrl: Assets.imagesF4),
    Item(name: "Green Plates", price: 7.00, imageUrl: Assets.imagesF5),
    Item(
        name: "Ice Tray",
        price: 20.00,
        imageUrl: Assets.imagesF6,
        discount: 12.00),
    Item(name: "White Vase", price: 17.50, imageUrl: Assets.imagesF7),
    Item(name: "Pattern Plates", price: 6.00, imageUrl: Assets.imagesF8),
    Item(name: "Beige Mug", price: 4.50, imageUrl: Assets.imagesF9),
    Item(name: "Candle Holder", price: 11.00, imageUrl: Assets.imagesD1),
    Item(name: "White Wall Hanging", price: 15.00, imageUrl: Assets.imagesD2),
    Item(name: "White Figurine", price: 17.00, imageUrl: Assets.imagesD3),
    Item(name: "White Figurine", price: 14.50, imageUrl: Assets.imagesD4),
    Item(name: "Monstera Drop Dish", price: 10.00, imageUrl: Assets.imagesD5),
    Item(name: "Apart White Pendant", price: 8.00, imageUrl: Assets.imagesD6),
    Item(name: "Dark Brown Figurine", price: 10.00, imageUrl: Assets.imagesD7),
    Item(name: "Mint Wall Hanging", price: 13.00, imageUrl: Assets.imagesD8),
    Item(name: "White Candle Holder", price: 10.00, imageUrl: Assets.imagesD9),
    Item(name: "Grey Utensil Holder", price: 5.00, imageUrl: Assets.imagesT1),
    Item(name: "Spice Jars", price: 9.00, imageUrl: Assets.imagesT2),
    Item(name: "Brown Fruit Bowl", price: 10.00, imageUrl: Assets.imagesT3),
    Item(name: "Black Butter Dishes", price: 13.00, imageUrl: Assets.imagesT4),
    Item(
        name: "Salt And Sugar Holder", price: 11.00, imageUrl: Assets.imagesT5),
    Item(name: "Beige Utensil Holder", price: 6.00, imageUrl: Assets.imagesT6),
    Item(name: "Candle Holder", price: 15.00, imageUrl: Assets.imagesT7),
    Item(name: "White Bread Basket", price: 8.00, imageUrl: Assets.imagesT8),
    Item(name: "White Serving Dishes", price: 7.50, imageUrl: Assets.imagesT9),
    Item(name: "Hanging Curio Shelf", price: 15.00, imageUrl: Assets.imagesO1),
    Item(name: "Brown Canisters", price: 12.00, imageUrl: Assets.imagesO2),
    Item(
        name: "White And Beige Canisters",
        price: 10.00,
        imageUrl: Assets.imagesO3),
    Item(name: "White Jewelry Holder", price: 8.00, imageUrl: Assets.imagesO4),
    Item(name: "White Jewelry Holder", price: 7.00, imageUrl: Assets.imagesO5),
    Item(name: "Office Supplies", price: 12.00, imageUrl: Assets.imagesO6),
    Item(name: "Brown Pen Holder", price: 6.00, imageUrl: Assets.imagesO7),
    Item(name: "Beige Pen Holder", price: 9.00, imageUrl: Assets.imagesO8),
    Item(name: "Pen Holder", price: 8.00, imageUrl: Assets.imagesO9),
    // Add more items...
  ];

  // Add a named 'key' parameter to the constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: ListView.builder(
        itemCount: allItems.length,
        itemBuilder: (ctx, i) => ItemCard(item: allItems[i]),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
            child: Icon(Icons.favorite),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/shopping');
            },
            child: Icon(Icons.shopping_cart),
          ),
        ],
      ),
    );
  }
}
