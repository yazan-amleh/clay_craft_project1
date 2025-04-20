import 'package:clay_craft_project/eighth_page.dart';
import 'package:clay_craft_project/eleventh_page.dart';
import 'package:clay_craft_project/fav_page.dart';
import 'package:clay_craft_project/ninth_page.dart';
import 'package:clay_craft_project/seventh_page.dart';
import 'package:clay_craft_project/shopping_page.dart';
import 'package:clay_craft_project/tenth_page.dart';
import 'package:clay_craft_project/twelfth_page.dart';
import 'package:clay_craft_project/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:clay_craft_project/provider/pottery_data_provider.dart';

class SixthPage extends StatefulWidget {
  const SixthPage({super.key});

  @override
  State<SixthPage> createState() => _SixthPageState();
}

class _SixthPageState extends State<SixthPage> {
  final PotteryDataProvider _dataProvider = PotteryDataProvider();
  
  bool _isLoading = true;
  List<PotteryItem> functionalPotteryItems = [];
  List<PotteryItem> decorativePotteryItems = [];
  List<PotteryItem> tablewarePotteryItems = [];
  List<PotteryItem> organizationalPotteryItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // استخدام الأسلوب المباشر للحصول على المنتجات من مزود البيانات
      await Future.delayed(const Duration(milliseconds: 500)); // تأخير قصير للتحميل
      
      setState(() {
        functionalPotteryItems = _dataProvider.getItemsByCategory('Functional Pottery');
        decorativePotteryItems = _dataProvider.getItemsByCategory('Decorative Pottery');
        tablewarePotteryItems = _dataProvider.getItemsByCategory('Tableware Pottery');
        organizationalPotteryItems = _dataProvider.getItemsByCategory('Organizational Pottery');
        _isLoading = false;
      });
      
      print('تم تحميل المنتجات: ${functionalPotteryItems.length} وظيفية, ${decorativePotteryItems.length} زخرفية, ${tablewarePotteryItems.length} أدوات مائدة, ${organizationalPotteryItems.length} تنظيمية');
    } catch (e) {
      print('خطأ في تحميل المنتجات: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(209, 192, 171, 1),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildSearchBar(),
            _isLoading 
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Expanded(child: _buildPotteryCategories(context)),
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: const Color(0xFFD6CFC4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EleventhPage()),
              );
            },
          ),
          const Text(
            "Clay Craft",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadItems,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search...",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPotteryCategories(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySection(
              context,
              "Functional Pottery",
              functionalPotteryItems,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeventhPage(
                    potteryItems: functionalPotteryItems,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCategorySection(
              context,
              "Decorative Pottery",
              decorativePotteryItems,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EighthPage(
                    potteryItems: decorativePotteryItems,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCategorySection(
              context,
              "Tableware Pottery",
              tablewarePotteryItems,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NinthPage(
                    potteryItems: tablewarePotteryItems,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCategorySection(
              context,
              "Organizational Pottery",
              organizationalPotteryItems,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TenthPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String title,
    List<PotteryItem> items,
    VoidCallback onViewAll,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text(
                "View All",
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    "لا توجد منتجات في هذه الفئة",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length > 5 ? 5 : items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              name: item.name,
                              price: item.price,
                              imageUrl: item.imageUrl,
                              videoUrl: item.videoUrl,
                              documentId: item.documentId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${item.price.toStringAsFixed(2)} JD",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      color: const Color(0xFFD6CFC4),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              // Already on home page
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShoppingPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/customer/orders');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TwelfthPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
