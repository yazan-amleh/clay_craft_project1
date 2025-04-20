import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // For development purposes, set to true to bypass email verification
  // IMPORTANT: Set to false in production!
  final bool _bypassEmailVerification = kDebugMode;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Check if email is verified
  bool isEmailVerified(User user) {
    // If bypass is enabled and in debug mode, return true
    if (_bypassEmailVerification) {
      return true;
    }
    return user.emailVerified;
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    } else {
      throw Exception('No user is signed in or email is already verified');
    }
  }

  // Sign up with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String firstName, 
    String lastName, 
    String mobile,
    bool isAdmin
  ) async {
    try {
      // Create the user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Save additional user data to Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'mobile': mobile,
          'isAdmin': isAdmin,
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': false,
        });
        
        // Send email verification
        await userCredential.user!.sendEmailVerification();
      }
      
      return userCredential;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle(bool isAdmin) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      throw Exception('Google sign in was canceled');
    }
    
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    // Sign in with the credential
    UserCredential userCredential = await _auth.signInWithCredential(credential);
    
    // Check if this is a new user
    if (userCredential.additionalUserInfo?.isNewUser ?? false) {
      // Save additional user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': googleUser.displayName?.split(' ').first ?? '',
        'lastName': googleUser.displayName?.split(' ').last ?? '',
        'email': googleUser.email,
        'mobile': '',
        'isAdmin': isAdmin,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': true, // Google accounts are considered verified
      });
    } else {
      // Check if the user is trying to access the correct section (admin or customer)
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['isAdmin'] != isAdmin) {
          await _auth.signOut();
          throw Exception(isAdmin 
            ? 'This account is not registered as an admin.' 
            : 'This account is registered as an admin. Please use the admin login.'
          );
        }
      }
    }
    
    return userCredential;
  }

  // Check if user is admin
  Future<bool> isUserAdmin(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return userData['isAdmin'] ?? false;
    }
    
    return false;
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    User? user = _auth.currentUser;
    if (user == null) {
      return false;
    }
    return await isUserAdmin(user.uid);
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }
    
    return null;
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return await getUserData(user.uid);
  }

  // Verify user role and access
  Future<bool> verifyUserAccess(bool requireAdmin) async {
    User? user = _auth.currentUser;
    if (user == null) {
      return false;
    }
    
    // First check if email is verified
    if (!isEmailVerified(user)) {
      return false;
    }
    
    // Then check if user has the correct role
    bool isAdmin = await isUserAdmin(user.uid);
    return requireAdmin ? isAdmin : !isAdmin;
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }
    
    return null;
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }
  
  // Update email verification status in Firestore
  Future<void> updateEmailVerificationStatus(String userId, bool verified) async {
    await _firestore.collection('users').doc(userId).update({
      'emailVerified': verified,
    });
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }
}
