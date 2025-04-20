import 'package:flutter/material.dart';
import 'package:clay_craft_project/services/auth_service.dart';
import 'package:clay_craft_project/navigation/app_router.dart';

/// RouteGuard provides protection for routes based on authentication and role
class RouteGuard {
  static final AuthService _authService = AuthService();

  /// Protect a widget with authentication and admin role check
  static Widget protectAdminRoute(Widget child, BuildContext context) {
    return FutureBuilder<bool>(
      future: AppRouter.canAccessAdminRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        } else {
          // Unauthorized access, redirect to admin login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You need to be logged in as an admin to access this page'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRouter.adminLogin, 
              (route) => false,
            );
          });
          
          return const Scaffold(
            body: Center(
              child: Text('Redirecting...'),
            ),
          );
        }
      },
    );
  }

  /// Protect a widget with authentication and customer role check
  static Widget protectCustomerRoute(Widget child, BuildContext context) {
    return FutureBuilder<bool>(
      future: AppRouter.canAccessCustomerRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return child;
        } else {
          // Unauthorized access, redirect to customer login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You need to be logged in as a customer to access this page'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRouter.customerLogin, 
              (route) => false,
            );
          });
          
          return const Scaffold(
            body: Center(
              child: Text('Redirecting...'),
            ),
          );
        }
      },
    );
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return _authService.currentUser != null;
  }

  /// Check if authenticated user is an admin
  static Future<bool> isAuthenticatedAdmin() async {
    if (await isAuthenticated()) {
      return await _authService.isCurrentUserAdmin();
    }
    return false;
  }

  /// Check if authenticated user is a customer
  static Future<bool> isAuthenticatedCustomer() async {
    if (await isAuthenticated()) {
      bool isAdmin = await _authService.isCurrentUserAdmin();
      return !isAdmin;
    }
    return false;
  }
}
