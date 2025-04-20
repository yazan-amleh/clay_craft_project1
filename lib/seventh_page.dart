import 'package:clay_craft_project/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:clay_craft_project/app_images.dart';
import 'package:clay_craft_project/services/firestore_service.dart';
import 'package:clay_craft_project/provider/pottery_data_provider.dart';
import 'package:clay_craft_project/twelfth_page.dart';
import 'package:clay_craft_project/shopping_page.dart';
import 'package:clay_craft_project/sixth_page.dart';
import 'package:clay_craft_project/fav_page.dart';
import 'eleventh_page.dart';

class SeventhPage extends StatefulWidget {
  final List<PotteryItem> potteryItems;

  const SeventhPage({super.key, required this.potteryItems});

  @override
  State<SeventhPage> createState() => _SeventhPageState();
}

class _SeventhPageState extends State<SeventhPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<PotteryItem> _functionalItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFirestoreItems();
  }

  Future<void> _loadFirestoreItems() async {
    // Escuchar los elementos de Firestore de la categoría "Functional"
    _firestoreService.getPotteryItemsByCategory('Functional').listen((items) {
      if (mounted) {
        setState(() {
          _functionalItems = items;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usar los elementos de Firestore si están disponibles, de lo contrario usar los elementos proporcionados
    final displayItems = _functionalItems.isNotEmpty ? _functionalItems : widget.potteryItems;

    return Scaffold(
      backgroundColor: const Color(0xFFD1C0AB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1C0AB),
        title: const SearchBar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const TwelfthPage()));
            },
          ),
          const SizedBox(width: 10),
        ],
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const EleventhPage()));
          },
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          const HeaderImage(),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: displayItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return PotteryItemCard(item: displayItems[index]);
                  },
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(209, 192, 171, 1),
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShoppingPage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SixthPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavPage()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
        ],
      ),
    );
  }
}

// SearchBar remains unchanged
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Color.fromARGB((0.7 * 255).toInt(), 255, 255, 255),
        hintText: 'Functional pottery',
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

// HeaderImage remains unchanged
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
  final PotteryItem item;

  const PotteryItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.asset(
                  item.imageUrl,
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
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 108, 89, 63),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
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
