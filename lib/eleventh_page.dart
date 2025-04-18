import 'package:clay_craft_project/sixth_page.dart';
import 'package:flutter/material.dart';

class EleventhPage extends StatelessWidget {
  const EleventhPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA79A80), // Background color from image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Manage My Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AccountOption(title: "Email"),
            AccountOption(title: "Phone Number"),
            AccountOption(title: "Change Password"),
            AccountOption(title: "Delete Account"),
            AccountOption(title: "Your courses"),
            Spacer(),
            IconButton(
              icon: Icon(Icons.home, size: 30, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SixthPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AccountOption extends StatelessWidget {
  final String title;
  const AccountOption({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300], // Button color from image
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Go back when pressed
            },
          ),
        ),
      ),
    );
  }
}
