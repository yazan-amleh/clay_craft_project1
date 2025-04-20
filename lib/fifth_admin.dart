import 'package:flutter/material.dart';
import 'package:clay_craft_project/app_images.dart';
import 'package:clay_craft_project/services/firestore_service.dart';
import 'package:clay_craft_project/navigation/route_guards.dart';
import 'package:clay_craft_project/navigation/app_router.dart';
import 'package:clay_craft_project/services/auth_service.dart';
import 'package:clay_craft_project/provider/pottery_data_provider.dart';
import 'package:flutter/foundation.dart';

class FifthAdmin extends StatefulWidget {
  const FifthAdmin({super.key});

  @override
  State<FifthAdmin> createState() => _FifthAdminState();
}

class _FifthAdminState extends State<FifthAdmin> {
  final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return RouteGuard.protectAdminRoute(
      Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: const Color.fromARGB(255, 108, 89, 63),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _authService.signOut();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  AppRouter.home, 
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: const PotteryListScreen(),
      ),
      context,
    );
  }
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
      imageUrl: Assets.imagesO1,
      videoUrl: 'https://www.youtube.com/watch?v=abc123',
      category: 'Storage',
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

  final List<String> categories = [
    'Functional',
    'Decorative',
    'Tableware',
    'Storage',
  ];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController videoUrlController = TextEditingController();
  String selectedCategory = 'Functional';
  String selectedImage = Assets.imagesO1;
  final FirestoreService _firestoreService = FirestoreService();
  bool isLoading = false;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _loadPotteryItems();
    _setupFirestoreListener();
  }

  void _setupFirestoreListener() {
    if (isListening) return;
    
    isListening = true;
    _firestoreService.getPotteryItems().listen((items) {
      if (mounted) {
        setState(() {
          potteryItems = items;
          isLoading = false;
        });
        debugPrint('تم تحديث قائمة المنتجات من خلال المستمع: ${items.length} منتج');
      }
    }, onError: (error) {
      debugPrint('خطأ في المستمع: $error');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> _loadPotteryItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      final items = await _firestoreService.getAllPotteryItems();
      if (mounted) {
        setState(() {
          potteryItems = items;
          isLoading = false;
        });
        debugPrint('تم تحميل ${items.length} منتج');
      }
    } catch (e) {
      debugPrint('خطأ في تحميل المنتجات: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل المنتجات: $e')),
        );
      }
    }
  }

  void _showAddPotteryDialog() {
    nameController.clear();
    priceController.clear();
    videoUrlController.clear();
    selectedCategory = categories[0];
    selectedImage = availableImages[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Pottery Item'),
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
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: videoUrlController,
                    decoration: const InputDecoration(labelText: 'Video URL'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Image:'),
                  SizedBox(
                    height: 100,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: availableImages.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedImage = availableImages[index];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedImage == availableImages[index]
                                    ? Colors.blue
                                    : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Image.asset(
                              availableImages[index],
                              width: 80,
                              height: 80,
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill in all required fields')),
                  );
                  return;
                }

                final newItem = PotteryItem(
                  name: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  imageUrl: selectedImage,
                  videoUrl: videoUrlController.text,
                  category: selectedCategory,
                );

                setState(() {
                  isLoading = true;
                });

                try {
                  final docRef = await _firestoreService.addPotteryItem(newItem);
                  if (!mounted) return;
                  
                  setState(() {
                    isLoading = false;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تمت إضافة المنتج بنجاح بمعرف: ${docRef.id}')),
                  );
                  
                  // لا حاجة لاستدعاء _loadPotteryItems() لأن المستمع سيقوم بتحديث القائمة تلقائيًا
                } catch (e) {
                  debugPrint('خطأ في إضافة المنتج: $e');
                  if (!mounted) return;
                  
                  setState(() {
                    isLoading = false;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في إضافة المنتج: $e')),
                  );
                }

                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPotteryDialog(PotteryItem item, String documentId) {
    nameController.text = item.name;
    priceController.text = item.price.toString();
    videoUrlController.text = item.videoUrl;
    selectedCategory = item.category;
    selectedImage = item.imageUrl;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pottery Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: videoUrlController,
                decoration: const InputDecoration(labelText: 'Video URL'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Select Image:'),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableImages.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImage = availableImages[index];
                          Navigator.pop(context);
                          _showEditPotteryDialog(item, documentId);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedImage == availableImages[index]
                                ? Colors.blue
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          availableImages[index],
                          width: 80,
                          height: 80,
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill in all required fields')),
                );
                return;
              }

              final updatedItem = PotteryItem(
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                imageUrl: selectedImage,
                videoUrl: videoUrlController.text,
                category: selectedCategory,
                documentId: documentId,
              );

              setState(() {
                isLoading = true;
              });

              try {
                await _firestoreService.updatePotteryItem(documentId, updatedItem);
                if (!mounted) return;
                
                setState(() {
                  isLoading = false;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث المنتج بنجاح')),
                );
                
                // لا حاجة لاستدعاء _loadPotteryItems() لأن المستمع سيقوم بتحديث القائمة تلقائيًا
              } catch (e) {
                debugPrint('خطأ في تحديث المنتج: $e');
                if (!mounted) return;
                
                setState(() {
                  isLoading = false;
                });
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطأ في تحديث المنتج: $e')),
                );
              }

              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deletePotteryItem(String documentId) async {
    setState(() {
      isLoading = true;
    });
    
    try {
      await _firestoreService.deletePotteryItem(documentId);
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المنتج بنجاح')),
      );
      
      // لا حاجة لاستدعاء _loadPotteryItems() لأن المستمع سيقوم بتحديث القائمة تلقائيًا
    } catch (e) {
      debugPrint('خطأ في حذف المنتج: $e');
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في حذف المنتج: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : potteryItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد منتجات',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'اضغط على زر + لإضافة منتج جديد',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPotteryItems,
                  child: ListView.builder(
                    itemCount: potteryItems.length,
                    itemBuilder: (context, index) {
                      final item = potteryItems[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: Image.asset(
                            item.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('\$${item.price.toStringAsFixed(2)} - ${item.category}'),
                              if (item.documentId != null)
                                Text(
                                  'ID: ${item.documentId}',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditPotteryDialog(
                                      item, item.documentId ?? '');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Item'),
                                      content: const Text(
                                          'Are you sure you want to delete this item?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deletePotteryItem(
                                                item.documentId ?? '');
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 108, 89, 63),
        onPressed: _showAddPotteryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    videoUrlController.dispose();
    super.dispose();
  }
}
