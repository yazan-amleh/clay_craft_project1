import 'package:flutter/material.dart';
import 'package:clay_craft_project/provider/pottery_data_provider.dart';
import 'package:clay_craft_project/services/firestore_service.dart';

class EditPotteryScreen extends StatefulWidget {
  final PotteryItem item;
  final String documentId;
  final List<String> availableImages;
  final List<String> categories;
  final Function onUpdate;

  const EditPotteryScreen({
    Key? key,
    required this.item,
    required this.documentId,
    required this.availableImages,
    required this.categories,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<EditPotteryScreen> createState() => _EditPotteryScreenState();
}

class _EditPotteryScreenState extends State<EditPotteryScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController externalLinkController;
  late String selectedCategory;
  late String selectedImage;
  bool isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // تهيئة وحدات التحكم بالقيم الحالية للمنتج
    nameController = TextEditingController(text: widget.item.name);
    priceController = TextEditingController(text: widget.item.price.toString());
    externalLinkController = TextEditingController(text: widget.item.externalLink ?? '');
    
    // التأكد من أن الفئة المختارة موجودة في قائمة الفئات المتاحة
    if (widget.categories.contains(widget.item.category)) {
      selectedCategory = widget.item.category;
    } else {
      // إذا لم تكن الفئة موجودة، نختار الفئة الأولى كقيمة افتراضية
      selectedCategory = widget.categories.isNotEmpty ? widget.categories[0] : 'Functional';
    }
    
    selectedImage = widget.item.imageUrl;
  }

  @override
  void dispose() {
    // تنظيف الموارد عند إغلاق الشاشة
    nameController.dispose();
    priceController.dispose();
    externalLinkController.dispose();
    super.dispose();
  }

  // حفظ التغييرات
  Future<void> _saveChanges() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final updatedItem = PotteryItem(
        name: nameController.text,
        price: double.tryParse(priceController.text) ?? 0.0,
        imageUrl: selectedImage,
        videoUrl: '', // نستخدم قيمة فارغة بدلاً من حذف الحقل لتجنب التغييرات في هيكل البيانات
        category: selectedCategory,
        documentId: widget.documentId,
        externalLink: externalLinkController.text.isNotEmpty ? externalLinkController.text : null,
      );

      await _firestoreService.updatePotteryItem(widget.documentId, updatedItem);
      
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
      });
      
      // استدعاء وظيفة التحديث المقدمة من الشاشة الأم
      widget.onUpdate();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث المنتج بنجاح')),
      );
      
      // العودة إلى الشاشة السابقة
      Navigator.pop(context);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل المنتج'),
        backgroundColor: const Color.fromARGB(255, 108, 89, 63),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معلومات المنتج
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معلومات المنتج',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'اسم المنتج',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: priceController,
                            decoration: const InputDecoration(
                              labelText: 'السعر',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'الفئة',
                              border: OutlineInputBorder(),
                            ),
                            items: widget.categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // روابط المنتج
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'روابط المنتج',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextField(
                            controller: externalLinkController,
                            decoration: const InputDecoration(
                              labelText: 'رابط خارجي',
                              border: OutlineInputBorder(),
                              hintText: 'أدخل الرابط الذي سيفتح عند النقر على المنتج',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // اختيار الصورة
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'صورة المنتج',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('الصورة المختارة:'),
                          const SizedBox(height: 8),
                          Center(
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.asset(
                                selectedImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('اختر صورة أخرى:'),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.availableImages.length,
                              itemBuilder: (context, index) {
                                final image = widget.availableImages[index];
                                final isSelected = selectedImage == image;
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedImage = image;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected ? Colors.blue : Colors.grey,
                                        width: isSelected ? 3 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.asset(
                                      image,
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
                  
                  const SizedBox(height: 24),
                  
                  // زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 108, 89, 63),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'حفظ التغييرات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
