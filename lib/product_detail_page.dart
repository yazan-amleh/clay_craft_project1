import 'package:flutter/material.dart';
import 'package:clay_craft_project/shopping_page.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'provider/app_state.dart';
import 'items_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String name;
  final double price;
  final String imageUrl;
  final String? videoUrl;
  final String? documentId;
  final String? description;
  final double? discount;

  const ProductDetailPage({
    Key? key,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.videoUrl,
    this.documentId,
    this.description,
    this.discount,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    // Create an Item object for this product
    final item = Item(
      name: widget.name,
      price: widget.price,
      imageUrl: widget.imageUrl,
      discount: widget.discount,
      quantity: quantity,
    );
    
    final bool isFavorite = appState.isFavorite(item);
    final bool hasDiscount = widget.discount != null;
    final double displayPrice = hasDiscount ? widget.discount! : widget.price;
    
    return Scaffold(
      backgroundColor: const Color(0xFFD1C0AB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1C0AB),
        title: Text(
          widget.name,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
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
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Image.asset(
                widget.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            
            // معلومات المنتج
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 108, 89, 63),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (hasDiscount)
                            Text(
                              "${widget.price.toStringAsFixed(2)} JD",
                              style: const TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          Text(
                            "${displayPrice.toStringAsFixed(2)} JD",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: hasDiscount ? Colors.red : const Color.fromARGB(255, 108, 89, 63),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // الوصف
                  const Text(
                    'الوصف',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 108, 89, 63),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description ?? 'منتج فخاري يدوي الصنع من مجموعة Clay Craft. يتميز بجودة عالية وتصميم فريد يناسب مختلف الاستخدامات.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // رابط الفيديو إذا كان متوفراً
                  if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'فيديو توضيحي',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 108, 89, 63),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            try {
                              final Uri url = Uri.parse(widget.videoUrl!);
                              if (!await launchUrl(url)) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('لا يمكن فتح الرابط'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint('Error launching URL: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('خطأ: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 108, 89, 63),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.play_circle_outline, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'مشاهدة الفيديو',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // اختيار الكمية
                  Row(
                    children: [
                      const Text(
                        'الكمية:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 108, 89, 63),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color.fromARGB(255, 108, 89, 63)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (quantity > 1) {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              },
                              color: const Color.fromARGB(255, 108, 89, 63),
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              color: const Color.fromARGB(255, 108, 89, 63),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // زر إضافة إلى السلة
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 108, 89, 63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // إضافة المنتج إلى سلة التسوق مع الكمية المحددة
                        final itemToAdd = Item(
                          name: widget.name,
                          price: widget.price,
                          imageUrl: widget.imageUrl,
                          discount: widget.discount,
                          quantity: quantity,
                        );
                        
                        appState.addToShoppingList(itemToAdd);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تمت إضافة $quantity من ${widget.name} إلى سلة التسوق',
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: const Color.fromARGB(255, 108, 89, 63),
                            action: SnackBarAction(
                              label: 'عرض السلة',
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ShoppingPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'إضافة إلى السلة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
