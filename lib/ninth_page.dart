import 'package:clay_craft_project/eleventh_page.dart';
import 'package:clay_craft_project/fav_page.dart';
import 'package:clay_craft_project/product_detail_page.dart';
import 'package:clay_craft_project/shopping_page.dart';
import 'package:clay_craft_project/sixth_page.dart';
import 'package:clay_craft_project/twelfth_page.dart';
import 'package:flutter/material.dart';
import 'package:clay_craft_project/app_images.dart';
import 'package:clay_craft_project/services/firestore_service.dart';
import 'package:clay_craft_project/provider/pottery_data_provider.dart';
import 'package:flutter/foundation.dart';

class NinthPage extends StatefulWidget {
  final List<PotteryItem> potteryItems;
  const NinthPage({super.key, required this.potteryItems});

  @override
  State<NinthPage> createState() => _NinthPageState();
}

class _NinthPageState extends State<NinthPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<PotteryItem> _tablewareItems = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _loadTablewareItems();
  }

  Future<void> _loadTablewareItems() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // استرجاع البيانات مباشرة أولاً (للعرض السريع)
      final items = await _firestoreService.getAllPotteryItems();
      
      if (mounted) {
        setState(() {
          // تصفية العناصر للحصول على فئة Tableware فقط
          _tablewareItems = items.where((item) => item.category == 'Tableware').toList();
          _isLoading = false;
        });
        
        debugPrint('تم تحميل ${_tablewareItems.length} منتج من فئة Tableware');
      }
      
      // ثم إعداد المستمع للتحديثات المباشرة
      _setupFirestoreListener();
    } catch (e) {
      debugPrint('خطأ في تحميل منتجات Tableware: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'حدث خطأ أثناء تحميل المنتجات: $e';
        });
      }
    }
  }

  void _setupFirestoreListener() {
    if (_isListening) return;
    
    _isListening = true;
    _firestoreService.getPotteryItemsByCategory('Tableware').listen((items) {
      if (mounted) {
        setState(() {
          _tablewareItems = items;
          _isLoading = false;
          _hasError = false;
        });
        debugPrint('تم تحديث قائمة منتجات Tableware من خلال المستمع: ${items.length} منتج');
      }
    }, onError: (error) {
      debugPrint('خطأ في مستمع Tableware: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'حدث خطأ أثناء تحميل المنتجات: $error';
        });
      }
    });
  }

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
                        const TwelfthPage()),
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
                      const EleventhPage()),
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
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 108, 89, 63)),
                        ),
                        SizedBox(height: 16),
                        Text('جاري تحميل المنتجات...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadTablewareItems,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 108, 89, 63),
                              ),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    : _tablewareItems.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory, size: 48, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'لا توجد منتجات متاحة في هذه الفئة',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadTablewareItems,
                            color: const Color.fromARGB(255, 108, 89, 63),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GridView.builder(
                                itemCount: _tablewareItems.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // تغيير إلى 2 لعرض أفضل
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemBuilder: (context, index) {
                                  final item = _tablewareItems[index];
                                  return PotteryItemCard(
                                    firestoreItem: item,
                                  );
                                },
                              ),
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFD1C0AB),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SixthPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShoppingPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.search, color: Colors.grey),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip('All'),
          _buildChip('Popular'),
          _buildChip('New'),
          _buildChip('Discounted'),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.black),
      ),
    );
  }
}

class HeaderImage extends StatelessWidget {
  const HeaderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: AssetImage(Assets.imagesT1),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tableware Collection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Elegant and functional tableware for your home',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PotteryItemCard extends StatelessWidget {
  final PotteryItem? firestoreItem;
  final PotteryItem? staticItem;

  const PotteryItemCard({
    super.key,
    this.firestoreItem,
    this.staticItem,
  }) : assert(firestoreItem != null || staticItem != null);

  @override
  Widget build(BuildContext context) {
    final name = firestoreItem?.name ?? staticItem?.name ?? '';
    final price = firestoreItem?.price ?? staticItem?.price ?? 0.0;
    final imageUrl = firestoreItem?.imageUrl ?? staticItem?.imageUrl ?? '';
    final videoUrl = firestoreItem?.videoUrl ?? '';
    final documentId = firestoreItem?.documentId;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              name: name,
              price: price,
              imageUrl: imageUrl,
              videoUrl: videoUrl,
              documentId: documentId,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 108, 89, 63),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (documentId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'ID: ${documentId.substring(0, min(6, documentId.length))}...',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
  
  // Helper function to get minimum of two integers
  int min(int a, int b) {
    return a < b ? a : b;
  }
}
