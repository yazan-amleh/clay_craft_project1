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
  String _currentCurrency = 'JOD';

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

  void _showManageAccountDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final TextEditingController firstNameController = TextEditingController(
      text: _userData?['firstName'] ?? '',
    );
    final TextEditingController lastNameController = TextEditingController(
      text: _userData?['lastName'] ?? '',
    );
    final TextEditingController mobileController = TextEditingController(
      text: _userData?['mobile'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إدارة الحساب'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الأول',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم العائلة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _showChangePasswordDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA79A80),
                  foregroundColor: Colors.white,
                ),
                child: const Text('تغيير كلمة المرور'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.updateUserProfile(user.uid, {
                  'firstName': firstNameController.text,
                  'lastName': lastNameController.text,
                  'mobile': mobileController.text,
                });
                
                if (mounted) {
                  setState(() {
                    if (_userData != null) {
                      _userData!['firstName'] = firstNameController.text;
                      _userData!['lastName'] = lastNameController.text;
                      _userData!['mobile'] = mobileController.text;
                    }
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تحديث معلومات الحساب بنجاح')),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                developer.log('Error updating user profile: $e', name: 'profile.page', error: e);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('حدث خطأ: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA79A80),
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('كلمات المرور الجديدة غير متطابقة')),
                );
                return;
              }

              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                // إعادة المصادقة قبل تغيير كلمة المرور
                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: currentPasswordController.text,
                );
                await user.reauthenticateWithCredential(credential);
                
                // تغيير كلمة المرور
                await user.updatePassword(newPasswordController.text);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                developer.log('Error changing password: $e', name: 'profile.page', error: e);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('حدث خطأ: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA79A80),
              foregroundColor: Colors.white,
            ),
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر العملة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption('JOD', 'دينار أردني'),
            _buildCurrencyOption('USD', 'دولار أمريكي'),
            _buildCurrencyOption('EUR', 'يورو'),
            _buildCurrencyOption('SAR', 'ريال سعودي'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(String code, String name) {
    return RadioListTile<String>(
      title: Text(name),
      subtitle: Text(code),
      value: code,
      groupValue: _currentCurrency,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _currentCurrency = value;
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تغيير العملة إلى $name')),
          );
        }
      },
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الخصوصية'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سياسة الخصوصية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. نحن نجمع فقط المعلومات الضرورية لتقديم خدماتنا وتحسين تجربتك.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'البيانات التي نجمعها:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text('• معلومات الحساب (الاسم، البريد الإلكتروني، رقم الهاتف)'),
              Text('• بيانات الطلبات والمشتريات'),
              Text('• معلومات الجهاز والاستخدام'),
              SizedBox(height: 16),
              Text(
                'كيف نستخدم بياناتك:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text('• تقديم وتحسين خدماتنا'),
              Text('• معالجة الطلبات والدفعات'),
              Text('• التواصل معك بخصوص طلباتك'),
              Text('• تحسين تجربة المستخدم'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showSwitchAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تبديل الحساب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل ترغب في تسجيل الخروج وتسجيل الدخول بحساب آخر؟'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final authService = Provider.of<AuthService>(context, listen: false);
                      await authService.signOut();
                      
                      if (mounted) {
                        Navigator.of(context).pop(); // إغلاق الحوار
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          AppRouter.customerLogin, 
                          (route) => false
                        );
                      }
                    } catch (e) {
                      developer.log('Error signing out: $e', name: 'profile.page', error: e);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('حدث خطأ: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA79A80),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('نعم'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('لا'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                  InkWell(
                    onTap: isLoggedIn ? _showManageAccountDialog : null,
                    child: SettingsOption(
                      title: "إدارة حسابي",
                      hasTrailingIcon: true,
                      enabled: isLoggedIn,
                    ),
                  ),
                  InkWell(
                    onTap: _showCurrencyDialog,
                    child: SettingsOption(
                      title: "العملة",
                      trailingText: _currentCurrency,
                    ),
                  ),
                  InkWell(
                    onTap: _showPrivacyDialog,
                    child: const SettingsOption(
                      title: "الخصوصية",
                      hasTrailingIcon: true,
                    ),
                  ),
                  InkWell(
                    onTap: isLoggedIn ? _showSwitchAccountDialog : null,
                    child: SettingsOption(
                      title: "تبديل الحساب",
                      hasTrailingIcon: true,
                      enabled: isLoggedIn,
                    ),
                  ),
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
  final bool enabled;

  const SettingsOption({
    super.key,
    required this.title,
    this.hasTrailingIcon = false,
    this.trailingText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: enabled ? Colors.grey[300] : Colors.grey[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: enabled ? Colors.black : Colors.black54,
            ),
          ),
          trailing: trailingText != null
              ? Text(
                  trailingText!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: enabled ? Colors.black : Colors.black54,
                  ),
                )
              : hasTrailingIcon
                  ? Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: enabled ? Colors.black : Colors.black54,
                    )
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
