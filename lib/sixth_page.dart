import 'package:clay_craft_project/eighth_page.dart';
import 'package:clay_craft_project/eleventh_page.dart';
import 'package:clay_craft_project/fav_page.dart';
import 'package:clay_craft_project/fifth_page.dart';
import 'package:clay_craft_project/ninth_page.dart';
import 'package:clay_craft_project/seventh_page.dart';
import 'package:clay_craft_project/shopping_page.dart';
import 'package:clay_craft_project/tenth_page.dart';
import 'package:clay_craft_project/twelfth_page.dart';
import 'package:flutter/material.dart';
import 'package:clay_craft_project/app_images.dart';
import 'items_page.dart';

class SixthPage extends StatelessWidget {
  const SixthPage({super.key});
  static final List<Item> functionalPotteryItems = [
    Item(name: "White Plates", price: 10.00, imageUrl: Assets.imagesF1),
    Item(name: "Brown Plates", price: 8.50, imageUrl: Assets.imagesF2),
    Item(name: "Teapots Plates", price: 15.00, imageUrl: Assets.imagesF3),
    Item(name: "Blue Teapots", price: 11.00, imageUrl: Assets.imagesF4),
    Item(
        name: "Ice Tray",
        price: 20.00,
        imageUrl: Assets.imagesF6,
        discount: 12.00),
    Item(name: "White Vase", price: 17.50, imageUrl: Assets.imagesF7),
    Item(name: "Pattern Plates", price: 6.00, imageUrl: Assets.imagesF8),
    Item(name: "Beige Mug", price: 4.50, imageUrl: Assets.imagesF9),
  ];
  static final List<Item> decorativePotteryItems = [
    Item(name: "Candle Holder", price: 11.00, imageUrl: Assets.imagesD1),
    Item(name: "White Wall Hanging", price: 15.00, imageUrl: Assets.imagesD2),
    Item(name: "White Figurine", price: 17.00, imageUrl: Assets.imagesD3),
    Item(name: "White Figurine", price: 14.50, imageUrl: Assets.imagesD4),
    Item(name: "Monstera Drop Dish", price: 10.00, imageUrl: Assets.imagesD5),
    Item(name: "Apart White Pendant", price: 8.00, imageUrl: Assets.imagesD6),
    Item(name: "Dark Brown Figurine", price: 10.00, imageUrl: Assets.imagesD7),
    Item(name: "Mint Wall Hanging", price: 13.00, imageUrl: Assets.imagesD8),
    Item(name: "White Candle Holder", price: 10.00, imageUrl: Assets.imagesD9),
  ];
  static final List<Item> tablewarePotteryItems = [
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
  ];

  static final List<Item> storagePotteryItems = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(209, 192, 171, 1),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildSearchBar(),
            Expanded(child: _buildPotteryCategories(context)),
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Color(0xFFD6CFC4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EleventhPage()),
              );
            },
          ),
          Text("Menu", style: TextStyle(color: Colors.white, fontSize: 18)),
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TwelfthPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Find a pottery design",
          hintStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white24,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.white),
        ),
        style: TextStyle(color: const Color.fromARGB(255, 108, 89, 63)),
      ),
    );
  }

  Widget _buildPotteryCategories(BuildContext context) {
    final List<Map<String, String>> categories = [
      {"title": "Functional Pottery", "image": Assets.imagesF},
      {"title": "Decorative Pottery", "image": Assets.imagesD},
      {"title": "Tableware and Kitchenware Pottery", "image": Assets.imagesT},
      {"title": "Storage and Organization Pottery", "image": Assets.imagesOr},
    ];

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: _buildCategoryTile(
              category['title']!, category['image']!, context),
        );
      },
    );
  }

  Widget _buildCategoryTile(String title, String image, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == "Functional Pottery") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SeventhPage(potteryItems: functionalPotteryItems),
            ),
          );
        } else if (title == "Decorative Pottery") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EighthPage(potteryItems: decorativePotteryItems),
            ),
          );
        } else if (title == "Tableware and Kitchenware Pottery") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NinthPage(potteryItems: tablewarePotteryItems),
            ),
          );
        } else if (title == "Storage and Organization Pottery") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TenthPage()),
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(
              image,
              fit: BoxFit.cover,
              height: 140,
              width: double.infinity,
            ),
            Container(
              height: 140,
              color: Color.fromARGB((0.7 * 255).toInt(), 255, 255, 255),
              alignment: Alignment.center,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 108, 89, 63),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      color: Color(0xFFD6CFC4),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingPage()),
              );
            },
            child: Icon(Icons.shopping_cart, color: Colors.white),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FifthPage()),
              );
            },
            child: Icon(Icons.home, color: Colors.white),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavPage()),
              );
            },
            child: Icon(Icons.favorite, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
