import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/app_state.dart';
import 'item_card.dart';
import 'fifth_page.dart';

class FavPage extends StatelessWidget {
  const FavPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteItems = Provider.of<AppState>(context).favoriteItems;

    return Scaffold(
      backgroundColor: const Color(0xFFD1C0AB),
      appBar: AppBar(
        backgroundColor: Color(0xFFD1C0AB),
        title: const Text(
          'Favorites List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: GridView.builder(
        itemCount: favoriteItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) => ItemCard(item: favoriteItems[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FifthPage()),
          );
        },
        backgroundColor: Color(0xFFD1C0AB),
        child:
            Icon(Icons.home, color: const Color.fromARGB(255, 255, 255, 255)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
