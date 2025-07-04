import 'package:clay_craft_project/eleventh_page.dart';
import 'package:clay_craft_project/fav_page.dart';
import 'package:clay_craft_project/shopping_page.dart';
import 'package:clay_craft_project/sixth_page.dart';
import 'package:clay_craft_project/twelfth_page.dart';
import 'package:flutter/material.dart';
import 'package:clay_craft_project/app_images.dart';
import 'package:clay_craft_project/services/firestore_service.dart';
import 'package:clay_craft_project/provider/pottery_data_provider.dart';

class EighthPage extends StatefulWidget {
  final List<PotteryItem> potteryItems;
  const EighthPage({super.key, required this.potteryItems});

  @override
  State<EighthPage> createState() => _EighthPageState();
}

class _EighthPageState extends State<EighthPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<PotteryItem> _decorativePotteryItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDecorativePotteryItems();
  }

  Future<void> _loadDecorativePotteryItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // استمع إلى تغييرات منتجات فئة Decorative Pottery
      _firestoreService.getPotteryItemsByCategory('Decorative Pottery').listen((items) {
        if (mounted) {
          setState(() {
            _decorativePotteryItems = items;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      print('Error loading decorative pottery items: $e');
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
                ? const Center(child: CircularProgressIndicator())
                : _decorativePotteryItems.isEmpty
                    ? const Center(child: Text('No decorative pottery items found'))
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          itemCount: _decorativePotteryItems.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            final item = _decorativePotteryItems[index];
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

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Color.fromARGB((0.7 * 255).toInt(), 255, 255, 255),
        hintText: 'Decorative pottery',
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
    "Sculptural Pieces",
    "Wall Hangings or Tiles",
    "Lanterns and Candle Holders"
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: categories
          .map((cat) => Chip(
                label: Text(cat),
                backgroundColor:
                    Color.fromARGB((0.7 * 255).toInt(), 255, 255, 255),
              ))
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
