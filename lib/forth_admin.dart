import 'package:flutter/material.dart';
import 'package:clay_craft_project/app_images.dart';
import 'package:clay_craft_project/seventh_page.dart';
import 'package:clay_craft_project/sixth_page.dart'; // Import customer home page
import 'package:clay_craft_project/provider/pottery_data_provider.dart';
import 'package:clay_craft_project/services/firestore_service.dart';
import 'package:flutter/foundation.dart';

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
  
  // Firestore service for persistent storage
  final FirestoreService _firestoreService = FirestoreService();

  // Add an item to the appropriate category list
  Future<void> addItem(PotteryItem item) async {
    try {
      // أولاً، أضف المنتج إلى Firestore للتخزين الدائم
      final docRef = await _firestoreService.addPotteryItem(item);
      
      // ثم أضف المنتج إلى القائمة المحلية المناسبة مع معرف المستند
      final itemWithId = PotteryItem(
        name: item.name,
        price: item.price,
        imageUrl: item.imageUrl,
        videoUrl: item.videoUrl,
        category: item.category,
        documentId: docRef.id,
      );
      
      // أضف المنتج إلى القائمة المناسبة حسب الفئة
      switch (item.category) {
        case 'Functional Pottery':
          functionalItems.add(itemWithId);
          break;
        case 'Decorative Pottery':
          decorativeItems.add(itemWithId);
          break;
        case 'Tableware Pottery':
          tablewareItems.add(itemWithId);
          break;
        case 'Organizational Pottery':
          organizationalItems.add(itemWithId);
          break;
      }
      
      debugPrint('تمت إضافة المنتج "${item.name}" بنجاح إلى Firestore ومزامنته محلياً');
    } catch (e) {
      debugPrint('خطأ في إضافة المنتج: $e');
      rethrow;
    }
  }

  // Update an item
  Future<void> updateItem(PotteryItem oldItem, PotteryItem newItem) async {
    try {
      // تحديث المنتج في Firestore إذا كان له معرف
      if (oldItem.documentId != null) {
        await _firestoreService.updatePotteryItem(oldItem.documentId!, newItem);
        debugPrint('تم تحديث المنتج في Firestore بمعرف: ${oldItem.documentId}');
      }
      
      // Remove from old category if category changed
      if (oldItem.category != newItem.category) {
        removeItem(oldItem);
      }

      // إنشاء نسخة من المنتج الجديد مع الاحتفاظ بمعرف المستند
      final updatedItem = PotteryItem(
        name: newItem.name,
        price: newItem.price,
        imageUrl: newItem.imageUrl,
        videoUrl: newItem.videoUrl,
        category: newItem.category,
        documentId: oldItem.documentId,
      );

      // Add to new category or update in existing category
      switch (newItem.category) {
        case 'Functional Pottery':
          int index = functionalItems.indexWhere((item) =>
              item.name == oldItem.name && item.imageUrl == oldItem.imageUrl);
          if (index >= 0) {
            functionalItems[index] = updatedItem;
          } else {
            functionalItems.add(updatedItem);
          }
          break;
        case 'Decorative Pottery':
          int index = decorativeItems.indexWhere((item) =>
              item.name == oldItem.name && item.imageUrl == oldItem.imageUrl);
          if (index >= 0) {
            decorativeItems[index] = updatedItem;
          } else {
            decorativeItems.add(updatedItem);
          }
          break;
        case 'Tableware Pottery':
          int index = tablewareItems.indexWhere((item) =>
              item.name == oldItem.name && item.imageUrl == oldItem.imageUrl);
          if (index >= 0) {
            tablewareItems[index] = updatedItem;
          } else {
            tablewareItems.add(updatedItem);
          }
          break;
        case 'Organizational Pottery':
          int index = organizationalItems.indexWhere((item) =>
              item.name == oldItem.name && item.imageUrl == oldItem.imageUrl);
          if (index >= 0) {
            organizationalItems[index] = updatedItem;
          } else {
            organizationalItems.add(updatedItem);
          }
          break;
      }
    } catch (e) {
      debugPrint('خطأ في تحديث المنتج: $e');
      rethrow;
    }
  }

  // Remove an item from its category list
  Future<void> removeItem(PotteryItem item) async {
    try {
      // حذف المنتج من Firestore إذا كان له معرف
      if (item.documentId != null) {
        await _firestoreService.deletePotteryItem(item.documentId!);
        debugPrint('تم حذف المنتج من Firestore بمعرف: ${item.documentId}');
      }
      
      // حذف المنتج من القائمة المحلية المناسبة
      switch (item.category) {
        case 'Functional Pottery':
          functionalItems.removeWhere(
              (i) => i.name == item.name && i.imageUrl == item.imageUrl);
          break;
        case 'Decorative Pottery':
          decorativeItems.removeWhere(
              (i) => i.name == item.name && i.imageUrl == item.imageUrl);
          break;
        case 'Tableware Pottery':
          tablewareItems.removeWhere(
              (i) => i.name == item.name && i.imageUrl == item.imageUrl);
          break;
        case 'Organizational Pottery':
          organizationalItems.removeWhere(
              (i) => i.name == item.name && i.imageUrl == item.imageUrl);
          break;
      }
    } catch (e) {
      debugPrint('خطأ في حذف المنتج: $e');
      rethrow;
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
        return functionalItems;
      case 'Decorative Pottery':
        return decorativeItems;
      case 'Tableware Pottery':
        return tablewareItems;
      case 'Organizational Pottery':
        return organizationalItems;
      default:
        return [];
    }
  }

  // تحميل المنتجات من Firestore
  Future<void> loadItemsFromFirestore() async {
    try {
      debugPrint('جاري تحميل المنتجات من Firestore...');
      
      // مسح القوائم المحلية
      functionalItems.clear();
      decorativeItems.clear();
      tablewareItems.clear();
      organizationalItems.clear();
      
      // الحصول على جميع المنتجات
      final items = await _firestoreService.getAllPotteryItems();
      
      // تصنيف المنتجات حسب الفئة
      for (var item in items) {
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
      
      debugPrint('تم تحميل ${items.length} منتج من Firestore');
    } catch (e) {
      debugPrint('خطأ في تحميل المنتجات من Firestore: $e');
      rethrow;
    }
  }

  // Convert PotteryItem objects to Item objects for customer view
  List<PotteryItem> convertToItems(List<PotteryItem> potteryItems) {
    return potteryItems.map((item) => PotteryItem(
          name: item.name,
          price: item.price,
          imageUrl: item.imageUrl,
          videoUrl: item.videoUrl,
          category: item.category,
          documentId: item.documentId,
        )).toList();
  }
}

class ForthAdmin extends StatelessWidget {
  const ForthAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const PotteryListScreen();
  }
}

class PotteryListScreen extends StatefulWidget {
  const PotteryListScreen({super.key});

  @override
  State<PotteryListScreen> createState() => _PotteryListScreenState();
}

class _PotteryListScreenState extends State<PotteryListScreen> {
  final dataProvider = PotteryDataProvider();
  final firestoreService = FirestoreService();
  List<PotteryItem> potteryItems = [];
  bool _isLoading = true;

  // Controllers for adding/editing items
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  String selectedCategory = 'Functional Pottery';
  String? selectedImage;

  // قوائم الصور المتاحة لكل فئة
  final Map<String, List<String>> categoryImages = {
    'Functional Pottery': [
      Assets.imagesF1,
      Assets.imagesF2,
      Assets.imagesF3,
      Assets.imagesF4,
      Assets.imagesF6,
      Assets.imagesF7,
      Assets.imagesF8,
      Assets.imagesF9,
    ],
    'Decorative Pottery': [
      Assets.imagesD1,
      Assets.imagesD2,
      Assets.imagesD3,
      Assets.imagesD4,
      Assets.imagesD5,
      Assets.imagesD6,
      Assets.imagesD7,
      Assets.imagesD8,
      Assets.imagesD9,
    ],
    'Tableware Pottery': [
      Assets.imagesT1,
      Assets.imagesT2,
      Assets.imagesT3,
      Assets.imagesT4,
      Assets.imagesT5,
      Assets.imagesT6,
      Assets.imagesT7,
      Assets.imagesT8,
      Assets.imagesT9,
    ],
    'Organizational Pottery': [
      Assets.imagesO1,
      Assets.imagesO2,
      Assets.imagesO3,
      Assets.imagesO4,
      Assets.imagesO5,
      Assets.imagesO6,
      Assets.imagesO7,
      Assets.imagesO8,
      Assets.imagesO9,
    ],
  };

  // الصور المتاحة حالياً بناءً على الفئة المختارة
  List<String> get availableImages => categoryImages[selectedCategory] ?? [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }
  
  // تحميل المنتجات من Firestore
  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await dataProvider.loadItemsFromFirestore();
      
      setState(() {
        potteryItems = dataProvider.getAllItems();
        _isLoading = false;
      });
      
      debugPrint('تم تحميل ${potteryItems.length} منتج');
    } catch (e) {
      debugPrint('خطأ في تحميل المنتجات: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Navigate to category view
  void _navigateToCategory(String category) {
    final categoryItems = dataProvider.getItemsByCategory(category);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeventhPage(
          potteryItems: categoryItems,
        ),
      ),
    );
  }

  // Navigate to customer home page
  void _navigateToCustomerView() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SixthPage()),
    );
  }

  // Show dialog to add or edit an item
  void _showItemDialog({PotteryItem? itemToEdit, int? index}) {
    // If editing, populate the controllers
    if (itemToEdit != null) {
      nameController.text = itemToEdit.name;
      priceController.text = itemToEdit.price.toString();
      selectedCategory = itemToEdit.category;
      selectedImage = itemToEdit.imageUrl;
    } else {
      // Clear controllers for adding new item
      nameController.clear();
      priceController.clear();
      selectedCategory = 'Functional Pottery';
      selectedImage = categoryImages[selectedCategory]?.isNotEmpty == true ? 
                     categoryImages[selectedCategory]![0] : null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFDED0C1),
          title: Text(itemToEdit == null ? 'إضافة منتج جديد' : 'تعديل المنتج'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'اسم المنتج'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'السعر (JD)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'الفئة'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Functional Pottery', child: Text('Functional')),
                      DropdownMenuItem(
                          value: 'Decorative Pottery', child: Text('Decorative')),
                      DropdownMenuItem(
                          value: 'Tableware Pottery', child: Text('Tableware')),
                      DropdownMenuItem(
                          value: 'Organizational Pottery',
                          child: Text('Organizational')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedCategory = value;
                          // تحديث الصورة المختارة عند تغيير الفئة
                          if (categoryImages[selectedCategory]?.isNotEmpty == true) {
                            selectedImage = categoryImages[selectedCategory]![0];
                          } else {
                            selectedImage = null;
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('اختر صورة:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: categoryImages[selectedCategory]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final imagePath = categoryImages[selectedCategory]![index];
                        final isSelected = imagePath == selectedImage;
                        
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedImage = imagePath;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.brown)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB49C85),
              ),
              onPressed: () async {
                // Validate inputs
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    selectedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('الرجاء ملء جميع الحقول المطلوبة')),
                  );
                  return;
                }

                // Create new item
                final newItem = PotteryItem(
                  name: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  imageUrl: selectedImage!,
                  videoUrl: '', // إزالة استخدام حقل رابط الفيديو
                  category: selectedCategory,
                  documentId: itemToEdit?.documentId,
                );

                try {
                  setState(() {
                    _isLoading = true;
                  });
                  
                  if (itemToEdit == null) {
                    // Add new item
                    await dataProvider.addItem(newItem);
                  } else {
                    // Update existing item
                    await dataProvider.updateItem(itemToEdit, newItem);
                  }
                  
                  // إعادة تحميل المنتجات
                  await _loadItems();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(itemToEdit == null ? 'تمت إضافة المنتج بنجاح' : 'تم تحديث المنتج بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('حدث خطأ: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(itemToEdit == null ? 'إضافة' : 'تحديث', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
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
                  value: 'Organizational Pottery', child: Text('Organizational')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag, color: Colors.white),
            onPressed: _navigateToCustomerView,
            tooltip: 'View Customer Interface',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadItems,
            tooltip: 'تحديث المنتجات',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : potteryItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white70),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد منتجات',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة منتج جديد'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFB49C85),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () => _showItemDialog(),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: potteryItems.length,
                  itemBuilder: (context, index) {
                    final item = potteryItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  item.imageUrl,
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
                                            fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('${item.price.toStringAsFixed(2)} JD',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.grey)),
                                    Text('Category: ${item.category}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  // Confirm deletion
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('تأكيد الحذف'),
                                      content: const Text('هل أنت متأكد من حذف هذا المنتج؟'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('إلغاء'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('حذف', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  
                                  if (confirm == true) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    
                                    try {
                                      // Remove from data provider
                                      await dataProvider.removeItem(item);
                                      
                                      // إعادة تحميل المنتجات
                                      await _loadItems();
                                      
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('تم حذف المنتج بنجاح'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('حدث خطأ: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showItemDialog(itemToEdit: item, index: index),
                              ),
                            ],
                          ),
                        ),
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
