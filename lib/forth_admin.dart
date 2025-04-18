import 'package:clay_craft_project/items_page.dart';
import 'package:flutter/material.dart';
import 'package:clay_craft_project/app_images.dart';
import 'package:clay_craft_project/seventh_page.dart';
import 'package:clay_craft_project/sixth_page.dart'; // Import customer home page

// Create a singleton data provider to share items across pages
class PotteryDataProvider {
  // Singleton instance
  static final PotteryDataProvider _instance = PotteryDataProvider._internal();
  factory PotteryDataProvider() => _instance;
  PotteryDataProvider._internal();

  // Lists to store items by category
  final List<PotteryItem> functionalItems = [];
  final List<PotteryItem> decorativeItems = [];
  final List<PotteryItem> tablewareItems = [];
  final List<PotteryItem> organizationalItems = [];

  // Add an item to the appropriate category list
  void addItem(PotteryItem item) {
    switch (item.category) {
      case 'Functional Pottery':
        functionalItems.add(item);
        break;
      case 'Decorative Pottery':
        decorativeItems.add(item);
        break;
      case 'Tableware Pottery':
        tablewareItems.add(item);
        break;
      case 'Organizational Pottery':
        organizationalItems.add(item);
        break;
    }
  }

  // Update an item
  void updateItem(PotteryItem oldItem, PotteryItem newItem) {
    // Remove from old category if category changed
    if (oldItem.category != newItem.category) {
      removeItem(oldItem);
    }

    // Add to new category or update in existing category
    switch (newItem.category) {
      case 'Functional Pottery':
        int index = functionalItems.indexWhere((item) =>
            item.name == oldItem.name && item.imagePath == oldItem.imagePath);
        if (index >= 0) {
          functionalItems[index] = newItem;
        } else {
          functionalItems.add(newItem);
        }
        break;
      case 'Decorative Pottery':
        int index = decorativeItems.indexWhere((item) =>
            item.name == oldItem.name && item.imagePath == oldItem.imagePath);
        if (index >= 0) {
          decorativeItems[index] = newItem;
        } else {
          decorativeItems.add(newItem);
        }
        break;
      case 'Tableware Pottery':
        int index = tablewareItems.indexWhere((item) =>
            item.name == oldItem.name && item.imagePath == oldItem.imagePath);
        if (index >= 0) {
          tablewareItems[index] = newItem;
        } else {
          tablewareItems.add(newItem);
        }
        break;
      case 'Organizational Pottery':
        int index = organizationalItems.indexWhere((item) =>
            item.name == oldItem.name && item.imagePath == oldItem.imagePath);
        if (index >= 0) {
          organizationalItems[index] = newItem;
        } else {
          organizationalItems.add(newItem);
        }
        break;
    }
  }

  // Remove an item from its category list
  void removeItem(PotteryItem item) {
    switch (item.category) {
      case 'Functional Pottery':
        functionalItems.removeWhere(
            (i) => i.name == item.name && i.imagePath == item.imagePath);
        break;
      case 'Decorative Pottery':
        decorativeItems.removeWhere(
            (i) => i.name == item.name && i.imagePath == item.imagePath);
        break;
      case 'Tableware Pottery':
        tablewareItems.removeWhere(
            (i) => i.name == item.name && i.imagePath == item.imagePath);
        break;
      case 'organizational Pottery':
        organizationalItems.removeWhere(
            (i) => i.name == item.name && i.imagePath == item.imagePath);
        break;
    }
  }

  // Get all items combined
  List<PotteryItem> getAllItems() {
    return [
      ...functionalItems,
      ...decorativeItems,
      ...tablewareItems,
      ...organizationalItems,
    ];
  }

  // Get items by category
  List<PotteryItem> getItemsByCategory(String category) {
    switch (category) {
      case 'Functional Pottery':
        return List.from(functionalItems);
      case 'Decorative Pottery':
        return List.from(decorativeItems);
      case 'Tableware Pottery':
        return List.from(tablewareItems);
      case 'organizational Pottery':
        return List.from(organizationalItems);
      default:
        return [];
    }
  }

  // Convert PotteryItem list to Item list for SeventhPage
  List<Item> convertToItems(List<PotteryItem> potteryItems) {
    return potteryItems
        .map((pottery) => Item(
              name: pottery.name,
              price: pottery.price,
              imageUrl: pottery.imagePath,
              // discount is optional so we can omit it
            ))
        .toList();
  }
}

class ForthAdmin extends StatelessWidget {
  const ForthAdmin({super.key});

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
  String category;

  PotteryItem({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.category,
  });
}

class PotteryListScreen extends StatefulWidget {
  const PotteryListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PotteryListScreenState createState() => _PotteryListScreenState();
}

class _PotteryListScreenState extends State<PotteryListScreen> {
  final PotteryDataProvider dataProvider = PotteryDataProvider();
  late List<PotteryItem> potteryItems;

  final List<String> availableImages = [
    Assets.imagesO1,
    Assets.imagesO2,
    Assets.imagesD1,
    Assets.imagesF3,
    Assets.imagesT4,
    Assets.imagesF7,
    Assets.imagesF5,
  ];

  @override
  void initState() {
    super.initState();

    // Add sample item if data is empty
    if (dataProvider.getAllItems().isEmpty) {
      final sampleItem = PotteryItem(
        name: 'Candle Holder',
        price: 12.00,
        imagePath: Assets.imagesO1,
        category: 'Functional Pottery',
      );
      dataProvider.addItem(sampleItem);
    }

    // Get all items
    potteryItems = dataProvider.getAllItems();
  }

  // Navigate to category view
  void _navigateToCategory(String category) {
    final categoryItems = dataProvider.getItemsByCategory(category);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeventhPage(
          potteryItems: dataProvider.convertToItems(categoryItems),
        ),
      ),
    );
  }

  // Navigate to customer home page
  void _navigateToCustomerView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SixthPage(),
      ),
    );
  }

  void _showItemDialog({PotteryItem? itemToEdit, int? index}) {
    final isEditing = itemToEdit != null;
    String? selectedImage = itemToEdit?.imagePath ?? availableImages[0];
    String selectedCategory = itemToEdit?.category ?? 'Functional Pottery';
    final TextEditingController nameController =
        TextEditingController(text: itemToEdit?.name ?? '');
    final TextEditingController priceController =
        TextEditingController(text: itemToEdit?.price.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFDED0C1),
          title: Text(isEditing ? 'Edit Pottery Item' : 'Add New Pottery Item'),
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
                  onChanged: (value) => selectedImage = value,
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
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration:
                      const InputDecoration(labelText: 'Select Category'),
                  items: [
                    'Functional Pottery',
                    'Decorative Pottery',
                    'Tableware Pottery',
                    'Kitchenware Pottery'
                  ].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) selectedCategory = value;
                  },
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
                if (name.isNotEmpty &&
                    priceText.isNotEmpty &&
                    selectedImage != null) {
                  final price = double.tryParse(priceText);
                  if (price != null) {
                    final newItem = PotteryItem(
                      name: name,
                      price: price,
                      imagePath: selectedImage!,
                      category: selectedCategory,
                    );

                    setState(() {
                      // ignore: unnecessary_null_comparison
                      if (isEditing && index != null && itemToEdit != null) {
                        // Update in data provider
                        dataProvider.updateItem(itemToEdit, newItem);

                        // Update in local list
                        potteryItems[index] = newItem;
                      } else {
                        // Add to data provider
                        dataProvider.addItem(newItem);

                        // Add to local list
                        potteryItems.add(newItem);
                      }
                    });
                    Navigator.pop(context);
                  }
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
            const Text('Pottery Admin', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.category, color: Colors.white),
            onSelected: _navigateToCategory,
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'Functional Pottery', child: Text('Functional')),
              const PopupMenuItem(
                  value: 'Decorative Pottery', child: Text('Decorative')),
              const PopupMenuItem(
                  value: 'Tableware Pottery', child: Text('Tableware')),
              const PopupMenuItem(
                  value: 'Kitchenware Pottery', child: Text('Kitchenware')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag, color: Colors.white),
            onPressed: _navigateToCustomerView,
            tooltip: 'View Customer Interface',
          ),
          const SizedBox(width: 10),
        ],
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
                      const SizedBox(height: 4),
                      Text('${item.price.toStringAsFixed(2)} JD',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white70)),
                      Text('Category: ${item.category}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white60)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      // Remove from data provider
                      dataProvider.removeItem(item);

                      // Remove from local list
                      potteryItems.removeAt(index);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () =>
                      _showItemDialog(itemToEdit: item, index: index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(179, 255, 255, 255),
        child: const Icon(Icons.add, color: Color(0xFFB49C85), size: 28),
        onPressed: () => _showItemDialog(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFB49C85),
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Icon(Icons.home, color: Colors.white),
        ),
      ),
    );
  }
}
