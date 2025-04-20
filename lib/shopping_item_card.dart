import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'items_page.dart';
import 'provider/app_state.dart';

class ShoppingItemCard extends StatelessWidget {
  final Item item;

  const ShoppingItemCard({super.key, required this.item});

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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            
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
            
            // Quantity Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity Label
                Text(
                  "الكمية: ${item.quantity}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // Quantity Controls
                Row(
                  children: [
                    // Decrease Quantity Button
                    InkWell(
                      onTap: () {
                        appState.decrementQuantity(item);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB49C85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    // Quantity Display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "${item.quantity}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Increase Quantity Button
                    InkWell(
                      onTap: () {
                        appState.incrementQuantity(item);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB49C85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Remove Item Button
            InkWell(
              onTap: () {
                appState.removeFromShoppingList(item);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "إزالة",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
