import 'package:flutter/material.dart';
import 'items_page.dart';

class CoursesPage extends StatelessWidget {
  final Item item;

  const CoursesPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${item.name} Course")),
      body: Center(
        child: Text("Welcome to the course for ${item.name}!"),
      ),
    );
  }
}
