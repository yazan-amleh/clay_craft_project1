import 'package:flutter/material.dart';
import 'package:clay_craft_project/services/auth_service.dart';
import 'package:clay_craft_project/first_page.dart';
import 'package:clay_craft_project/second_page.dart';
import 'package:clay_craft_project/first_admin.dart';
import 'package:clay_craft_project/second_admin.dart';
import 'package:clay_craft_project/third_page.dart';
import 'package:clay_craft_project/fourth_page.dart';
import 'package:clay_craft_project/fifth_admin.dart';
import 'package:clay_craft_project/sixth_page.dart';
import 'package:clay_craft_project/seventh_page.dart';
import 'package:clay_craft_project/eighth_page.dart';
import 'package:clay_craft_project/ninth_page.dart';
import 'package:clay_craft_project/fourteenth_page.dart';
import 'package:clay_craft_project/fav_page.dart';
import 'package:clay_craft_project/shopping_page.dart';
import 'package:clay_craft_project/user/user_orders_page.dart';

/// AppRouter handles navigation and route management for the Clay Craft app.
/// It separates admin and customer routes and provides route guards.
class AppRouter {
  static final AuthService _authService = AuthService();
  
  // Named routes
  static const String home = '/';
  static const String roleSelection = '/role-selection';
  
  // Admin routes
  static const String adminLogin = '/admin/login';
  static const String adminSignup = '/admin/signup';
  static const String adminDashboard = '/admin/dashboard';
  
  // Customer routes
  static const String customerLogin = '/customer/login';
  static const String customerSignup = '/customer/signup';
  static const String customerHome = '/customer/home';
  static const String functionalPottery = '/customer/functional-pottery';
  static const String decorativePottery = '/customer/decorative-pottery';
  static const String tableware = '/customer/tableware';
  static const String storage = '/customer/storage';
  static const String favorites = '/customer/favorites';
  static const String shoppingCart = '/customer/shopping-cart';
  static const String userOrders = '/customer/orders';
  
  /// Generate route based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const FirstPage());
      
      case roleSelection:
        return MaterialPageRoute(builder: (_) => const SecondPage());
      
      // Admin routes
      case adminLogin:
        return MaterialPageRoute(builder: (_) => const FirstAdmin());
      
      case adminSignup:
        return MaterialPageRoute(builder: (_) => const SecondAdmin());
      
      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const FifthAdmin(),
          settings: settings,
        );
      
      // Customer routes
      case customerLogin:
        return MaterialPageRoute(builder: (_) => const ThirdPage());
      
      case customerSignup:
        return MaterialPageRoute(builder: (_) => const FourthPage());
      
      case customerHome:
        return MaterialPageRoute(builder: (_) => const SixthPage());
      
      case functionalPottery:
        return MaterialPageRoute(
          builder: (_) => const SeventhPage(potteryItems: []),
          settings: settings,
        );
      
      case decorativePottery:
        return MaterialPageRoute(
          builder: (_) => const EighthPage(potteryItems: []),
          settings: settings,
        );
      
      case tableware:
        return MaterialPageRoute(
          builder: (_) => const NinthPage(potteryItems: []),
          settings: settings,
        );
      
      case storage:
        return MaterialPageRoute(
          builder: (_) => const FourteenthPage(potteryItems: []),
          settings: settings,
        );
      
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavPage());
      
      case shoppingCart:
        return MaterialPageRoute(builder: (_) => const ShoppingPage());
      
      case userOrders:
        return MaterialPageRoute(builder: (_) => const UserOrdersPage());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  /// Navigate to the appropriate home page based on user role
  static Future<void> navigateToHomePage(BuildContext context) async {
    bool isLoggedIn = _authService.currentUser != null;
    
    if (!isLoggedIn) {
      Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
      return;
    }
    
    bool isAdmin = await _authService.isCurrentUserAdmin();
    
    if (isAdmin) {
      Navigator.pushNamedAndRemoveUntil(context, adminDashboard, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, customerHome, (route) => false);
    }
  }
  
  /// Check if user has access to admin routes
  static Future<bool> canAccessAdminRoute() async {
    return await _authService.verifyUserAccess(true);
  }
  
  /// Check if user has access to customer routes
  static Future<bool> canAccessCustomerRoute() async {
    return await _authService.verifyUserAccess(false);
  }
  
  /// Sign out and navigate to home
  static Future<void> signOutAndNavigateHome(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushNamedAndRemoveUntil(context, home, (route) => false);
  }
}
