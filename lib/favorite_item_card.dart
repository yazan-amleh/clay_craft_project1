import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'items_page.dart';
import 'provider/app_state.dart';
import 'product_detail_page.dart';

class FavoriteItemCard extends StatelessWidget {
  final Item item;

  const FavoriteItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final bool hasDiscount = item.discount != null;
    final double displayPrice = hasDiscount ? item.discount! : item.price;
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Favorite Icon
          Stack(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(
                  item.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              
              // Favorite Icon
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () {
                      appState.removeFromFavorites(item);
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
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
                    fontSize: 14,
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: hasDiscount ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // View Details Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
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
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB49C85),
                          side: const BorderSide(color: Color(0xFFB49C85)),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'عرض التفاصيل',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Add to Cart Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          appState.addToShoppingList(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تمت إضافة المنتج إلى سلة التسوق'),
                              backgroundColor: Color(0xFFB49C85),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB49C85),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'أضف للسلة',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
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
