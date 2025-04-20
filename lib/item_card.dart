import 'package:clay_craft_project/courses_page.dart';
import 'package:clay_craft_project/shopping_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/app_state.dart';
import 'items_page.dart'; // Make sure this contains the Item model
import 'product_detail_page.dart';

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final bool hasDiscount = item.discount != null;
    final double displayPrice = hasDiscount ? item.discount! : item.price;
    final bool isFavorite = appState.isFavorite(item);
    final bool isInCart = appState.isInShoppingList(item);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Tap Gesture
          Expanded(
            child: Stack(
              children: [
                // Image with tap for details
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          name: item.name,
                          price: item.price,
                          imageUrl: item.imageUrl,
                          videoUrl: '',
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: Image.asset(
                      item.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Discount Badge
                if (hasDiscount)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${(((item.price - item.discount!) / item.price) * 100).toStringAsFixed(0)}% خصم",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Product Details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Price Information
                Row(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        "${item.price.toStringAsFixed(2)} JD",
                        style: const TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      "${displayPrice.toStringAsFixed(2)} JD",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: hasDiscount ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Shopping Cart Button
                    IconButton(
                      icon: Icon(
                        isInCart ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                        size: 18,
                        color: isInCart ? const Color(0xFFB49C85) : Colors.grey,
                      ),
                      onPressed: () {
                        if (isInCart) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ShoppingPage(),
                            ),
                          );
                        } else {
                          appState.addToShoppingList(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تمت إضافة المنتج إلى سلة التسوق'),
                              backgroundColor: Color(0xFFB49C85),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                    
                    // Favorite Button
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        if (isFavorite) {
                          appState.removeFromFavorites(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تمت إزالة المنتج من المفضلة'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else {
                          appState.addToFavorites(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تمت إضافة المنتج إلى المفضلة'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                    
                    // Courses Button
                    IconButton(
                      icon: const Icon(
                        Icons.play_circle,
                        size: 18,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoursesPage(item: item),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
