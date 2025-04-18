import 'package:clay_craft_project/eleventh_page.dart';
import 'package:clay_craft_project/shopping_page.dart';
import 'package:clay_craft_project/thirteenth_page.dart';
import 'package:clay_craft_project/twelfth_page.dart';
import 'package:flutter/material.dart';
import 'package:clay_craft_project/app_images.dart';

const List<Map<String, String>> storagePotteryItems = [
  {
    "name": "Hanging Curio Shelf",
    "price": "15.00 JD",
    "image": Assets.imagesO1
  },
  {"name": "Brown Canisters", "price": "12.00 JD", "image": Assets.imagesO2},
  {
    "name": "White And Beige Canisters",
    "price": "10.00 JD",
    "image": Assets.imagesO3
  },
  {
    "name": "White Jewelry Holder",
    "price": "8.00 JD",
    "image": Assets.imagesO4
  },
  {
    "name": "White Jewelry Holder",
    "price": "7.00 JD",
    "image": Assets.imagesO5
  },
  {"name": "Office Supplies", "price": "12.00 JD", "image": Assets.imagesO6},
  {"name": "Brown Pen Holder", "price": "6.00 JD", "image": Assets.imagesO7},
  {"name": "Beige Pen Holder", "price": "9.00 JD", "image": Assets.imagesO8},
  {"name": "Pen Holder", "price": "8.00 JD", "image": Assets.imagesO9},
];

class SeventeenthPage extends StatelessWidget {
  const SeventeenthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1C0AB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1C0AB),
        title: const SearchBar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const TwelfthPage()), // Replace with your actual Person Page widget
              );
            },
          ),
          const SizedBox(width: 10),
        ],
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const EleventhPage()), // Replace with your actual Settings Page widget
            );
          },
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          const CategoryChips(),
          const HeaderImage(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: storagePotteryItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return PotteryItemCard(item: storagePotteryItems[index]);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(209, 192, 171, 1),
        onTap: (index) {
          // Handle navigation based on the index
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingPage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThirteenthPage()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.play_circle), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Color.fromARGB((0.7 * 255).toInt(), 255, 255, 255),
        hintText: 'Storage and Organization',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  final List<String> categories = const [
    "Canisters and Jars",
    "Jewelry Holders",
    "Pen Holders and Office Supplies"
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: categories
          .map((cat) => Chip(
              label: Text(cat),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255)))
          .toList(),
    );
  }
}

class HeaderImage extends StatelessWidget {
  const HeaderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Stack(
        children: [
          Image.asset(Assets.images2,
              fit: BoxFit.fitWidth, height: 150, width: 500),
          const Positioned(
            left: 10,
            bottom: 0,
            child: Text(
              'Handcrafted\nwith love',
              style: TextStyle(
                fontSize: 20,
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PotteryItemCard extends StatelessWidget {
  final Map<String, String> item;

  const PotteryItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB((0.7 * 255).toInt(), 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(item['image']!, fit: BoxFit.cover),
          ),
          Text(
            item['name']!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            item['price']!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.play_circle, size: 16),
            ],
          )
        ],
      ),
    );
  }
}
