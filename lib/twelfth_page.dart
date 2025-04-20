import 'package:clay_craft_project/sixth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:clay_craft_project/navigation/app_router.dart';

class TwelfthPage extends StatelessWidget {
  const TwelfthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;

    return Scaffold(
      backgroundColor: const Color(0xFFA79A80),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isLoggedIn) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            user.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // My Orders Button
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.userOrders);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const ListTile(
                    leading: Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFFA79A80),
                    ),
                    title: Text(
                      "طلباتي",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SettingsOption(
                title: "Manage My Account", hasTrailingIcon: true),
            const SettingsOption(title: "Currency", trailingText: "JOD"),
            const SettingsOption(title: "Privacy", hasTrailingIcon: true),
            const SettingsOption(
                title: "Switch Accounts", hasTrailingIcon: true),
            const Spacer(),
            const SignOutButton(),
            const SizedBox(height: 16),
            IconButton(
              icon: const Icon(Icons.home, size: 30, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SixthPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsOption extends StatelessWidget {
  final String title;
  final bool hasTrailingIcon;
  final String? trailingText;

  const SettingsOption({
    super.key,
    required this.title,
    this.hasTrailingIcon = false,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: trailingText != null
              ? Text(
                  trailingText!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              : hasTrailingIcon
                  ? const Icon(Icons.arrow_forward_ios, size: 16)
                  : null,
        ),
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  Future<void> _signOut(BuildContext context) async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signed out successfully")),
    );

    // Optional: Go back to login screen or root
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: () => _signOut(context),
        child: const Text(
          "Sign Out",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
