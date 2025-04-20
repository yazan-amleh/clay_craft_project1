import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clay_craft_project/navigation/app_router.dart';
import 'package:provider/provider.dart';
import 'package:clay_craft_project/services/auth_service.dart';
import 'dart:developer' as developer;

class TwelfthPage extends StatefulWidget {
  const TwelfthPage({super.key});

  @override
  State<TwelfthPage> createState() => _TwelfthPageState();
}

class _TwelfthPageState extends State<TwelfthPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    developer.log('Initializing profile page', name: 'profile.page');
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userData = await authService.getCurrentUserData();
      
      developer.log('User data loaded: ${userData != null}', name: 'profile.page');
      
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading user data: $e', name: 'profile.page', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;

    developer.log('Building profile page, user logged in: $isLoggedIn', name: 'profile.page');

    return Scaffold(
      backgroundColor: const Color(0xFFA79A80),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'الإعدادات',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Padding(
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
                                  _userData != null
                                      ? "${_userData!['firstName']} ${_userData!['lastName']}"
                                      : user.displayName ?? 'مستخدم',
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
                                if (_userData != null && _userData!['mobile'] != null && _userData!['mobile'].isNotEmpty)
                                  Text(
                                    _userData!['mobile'],
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
                        developer.log('Navigating to orders page', name: 'profile.page');
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
                      title: "إدارة حسابي", hasTrailingIcon: true),
                  const SettingsOption(title: "العملة", trailingText: "JOD"),
                  const SettingsOption(title: "الخصوصية", hasTrailingIcon: true),
                  const SettingsOption(
                      title: "تبديل الحساب", hasTrailingIcon: true),
                  const Spacer(),
                  isLoggedIn 
                      ? const SignOutButton()
                      : ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRouter.customerLogin);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFA79A80),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "تسجيل الدخول",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.home, size: 30, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context, 
                        AppRouter.customerHome, 
                        (route) => false
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
    try {
      developer.log('Signing out user', name: 'profile.page');
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تسجيل الخروج بنجاح")),
      );

      // Navigate to home page
      Navigator.pushNamedAndRemoveUntil(
        context, 
        AppRouter.home, 
        (route) => false
      );
    } catch (e) {
      developer.log('Error signing out: $e', name: 'profile.page', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("حدث خطأ أثناء تسجيل الخروج: $e")),
        );
      }
    }
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
          "تسجيل الخروج",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
