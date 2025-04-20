import 'package:clay_craft_project/eleventh_page.dart';
import 'package:clay_craft_project/fav_page.dart';
import 'package:clay_craft_project/items_page.dart';
import 'package:clay_craft_project/shopping_page.dart';
import 'package:clay_craft_project/sixth_page.dart';
import 'package:clay_craft_project/twelfth_page.dart';
import 'package:flutter/material.dart';
import 'package:clay_craft_project/app_images.dart';
import 'package:clay_craft_project/services/firestore_service.dart';
import 'package:clay_craft_project/provider/pottery_data_provider.dart';

class FourteenthPage extends StatefulWidget {
  final List<Item> potteryItems;
  const FourteenthPage({super.key, required this.potteryItems});

  @override
  State<FourteenthPage> createState() => _FourteenthPageState();
}

class _FourteenthPageState extends State<FourteenthPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<PotteryItem> _storageItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorageItems();
  }

  Future<void> _loadStorageItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // استمع إلى تغييرات منتجات فئة Storage
      _firestoreService.getPotteryItemsByCategory('Storage').listen((items) {
        if (mounted) {
          setState(() {
            _storageItems = items;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      print('Error loading storage items: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                MaterialPageRoute(builder: (context) => const TwelfthPage()),
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
              MaterialPageRoute(builder: (context) => const EleventhPage()),
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
                ? const Center(child: CircularProgressIndicator())
                : _storageItems.isEmpty
                    ? const Center(child: Text('No storage items found'))
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          itemCount: _storageItems.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            final item = _storageItems[index];
                            return PotteryItemCard(
                              firestoreItem: item,
                            );
                          },
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

// HeaderImage - can remain the same
class HeaderImage extends StatelessWidget {
  const HeaderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.imagesS),
          fit: BoxFit.cover,
        ),
      ),
      child: const Center(
        child: Text(
          'Storage',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// CategoryChips - can remain the same
class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Functional',
      'Decorative',
      'Tableware',
      'Storage',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ActionChip(
              label: Text(category,
                  style: TextStyle(
                    color: category == 'Storage' ? Colors.white : Colors.black,
                  )),
              backgroundColor: category == 'Storage' ? Colors.brown : null,
              onPressed: () {
                // Navigate to the selected category
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PotteryItemCard extends StatelessWidget {
  final PotteryItem? firestoreItem;
  final Map<String, String>? staticItem;

  const PotteryItemCard({super.key, this.firestoreItem, this.staticItem});

  @override
  Widget build(BuildContext context) {
    if (firestoreItem != null) {
      // إذا كان المنتج من Firestore
      return Container(
        decoration: BoxDecoration(
          color: Color.fromARGB((0.7 * 255).toInt(), 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Expanded(
              child: firestoreItem!.imageUrl.isNotEmpty
                  ? Image.network(
                      firestoreItem!.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported);
                      },
                    )
                  : const Icon(Icons.image_not_supported),
            ),
            Text(
              firestoreItem!.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            Text(
              '${firestoreItem!.price} JD',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      );
    } else if (staticItem != null) {
      // إذا كان المنتج من القائمة الثابتة
      return Container(
        decoration: BoxDecoration(
          color: Color.fromARGB((0.7 * 255).toInt(), 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(staticItem!['image']!, fit: BoxFit.cover),
            ),
            Text(
              staticItem!['name']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            Text(
              staticItem!['price']!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      );
    } else {
      // حالة الافتراضية إذا لم يتم توفير أي منتج
      return Container(
        decoration: BoxDecoration(
          color: Color.fromARGB((0.7 * 255).toInt(), 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('No item data'),
        ),
      );
    }
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
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Storage pottery',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
    );
  }
}
