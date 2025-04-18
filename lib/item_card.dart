import 'package:clay_craft_project/courses_page.dart';
import 'package:clay_craft_project/fav_page.dart';
import 'package:clay_craft_project/shopping_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/app_state.dart';
import 'items_page.dart'; // Make sure this contains the Item model

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = item.discount != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(item.imageUrl, fit: BoxFit.cover),
          ),
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            "${item.price.toStringAsFixed(2)} JD",
            style: TextStyle(
              fontSize: 12,
              color: hasDiscount ? Colors.grey : Colors.black,
              decoration: hasDiscount
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          if (hasDiscount)
            Text(
              "${item.discount!.toStringAsFixed(2)} JD",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 18),
                onPressed: () {
                  Provider.of<AppState>(context, listen: false)
                      .toggleShopping(item);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ShoppingPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, size: 18),
                onPressed: () {
                  Provider.of<AppState>(context, listen: false)
                      .toggleFavorite(item);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavPage()),
                  );
                },
              ),
              IconButton(
                icon:
                    const Icon(Icons.play_circle, size: 20, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CoursesPage(item: item)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
