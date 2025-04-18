import 'package:flutter/material.dart';
import 'package:clay_craft_project/app_images.dart';

void main() => runApp(const FifthAdmin());

class FifthAdmin extends StatelessWidget {
  const FifthAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PotteryListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PotteryItem {
  String name;
  double price;
  String imagePath;
  String videoLink;

  PotteryItem({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.videoLink,
    required String category,
  });
}

class PotteryListScreen extends StatefulWidget {
  const PotteryListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PotteryListScreenState createState() => _PotteryListScreenState();
}

class _PotteryListScreenState extends State<PotteryListScreen> {
  List<PotteryItem> potteryItems = [
    PotteryItem(
      name: 'Candle Holder',
      price: 12.00,
      imagePath: Assets.imagesO1,
      videoLink: 'https://www.youtube.com/watch?v=abc123',
      category: '',
    ),
  ];

  final List<String> availableImages = [
    Assets.imagesO1,
    Assets.imagesO2,
    Assets.imagesD1,
    Assets.imagesF3,
    Assets.imagesT4,
    Assets.imagesF7,
  ];

  void _showItemDialog({PotteryItem? itemToEdit, int? index}) {
    final isEditing = itemToEdit != null;
    String selectedImage = itemToEdit?.imagePath ?? availableImages[0];
    final TextEditingController nameController =
        TextEditingController(text: itemToEdit?.name ?? '');
    final TextEditingController priceController =
        TextEditingController(text: itemToEdit?.price.toString() ?? '');
    final TextEditingController videoLinkController =
        TextEditingController(text: itemToEdit?.videoLink ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFDED0C1),
          title: Text(isEditing ? 'Edit Pottery Item' : 'Add Pottery Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedImage,
                  items: availableImages.map((imgPath) {
                    return DropdownMenuItem(
                      value: imgPath,
                      child: Row(
                        children: [
                          Image.asset(imgPath,
                              width: 40, height: 40, fit: BoxFit.cover),
                          const SizedBox(width: 10),
                          Text(imgPath.split('/').last),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) selectedImage = value;
                  },
                  decoration: const InputDecoration(labelText: 'Select Image'),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price (JD)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: videoLinkController,
                  decoration: const InputDecoration(labelText: 'Video Link'),
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.brown)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB49C85),
              ),
              child: Text(isEditing ? 'Update' : 'Add'),
              onPressed: () {
                final name = nameController.text.trim();
                final priceText = priceController.text.trim();
                final video = videoLinkController.text.trim();
                final price = double.tryParse(priceText);

                if (name.isNotEmpty && price != null && video.isNotEmpty) {
                  setState(() {
                    final newItem = PotteryItem(
                      name: name,
                      price: price,
                      imagePath: selectedImage,
                      videoLink: video,
                      category: '',
                    );

                    if (isEditing && index != null) {
                      potteryItems[index] = newItem;
                    } else {
                      potteryItems.add(newItem);
                    }
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB49C85),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB49C85),
        title:
            const Text('Pottery List', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.white),
        actions: const [Icon(Icons.person, color: Colors.white)],
      ),
      body: ListView.builder(
        itemCount: potteryItems.length,
        itemBuilder: (context, index) {
          final item = potteryItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    item.imagePath,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white)),
                      Text('${item.price.toStringAsFixed(2)} JD',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white70)),
                      Text(
                        item.videoLink,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white60),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      potteryItems.removeAt(index);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    _showItemDialog(itemToEdit: item, index: index);
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFB49C85),
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(Icons.home, color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(179, 255, 255, 255),
        child: const Icon(Icons.add, color: Color(0xFFB49C85), size: 28),
        onPressed: () => _showItemDialog(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
}
