import 'package:flutter/material.dart';
import 'package:smart_finance_ai/models/user_profile.dart';

// Demo authentication provider without Firebase
class AuthProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isInitializing = true;
  bool _isLoggedIn = false;
  String _userId = '';

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state for demo
  Future<void> _initializeAuth() async {
    // Demo initialization - no actual Firebase
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    _isInitializing = false;
    notifyListeners();
  }

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;
  UserProfile? get userProfile => _userProfile;
  String get userId => _userId;

  // Sign up with email and password (Demo)
  Future<void> signUp(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Create a demo user
      _userId = 'demo-user-${DateTime.now().millisecondsSinceEpoch}';
      _userProfile = UserProfile(
        id: _userId,
        email: email,
        displayName: email.split('@').first,
        createdAt: DateTime.now(),
      );
      
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  // Sign in with email and password (Demo)
  Future<void> signIn(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Set demo user data
      _userId = 'demo-user-${DateTime.now().millisecondsSinceEpoch}';
      _userProfile = UserProfile(
        id: _userId,
        email: email,
        displayName: email.split('@').first,
        createdAt: DateTime.now(),
      );
      
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  // Sign out (Demo)
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    _isLoggedIn = false;
    _userId = '';
    _userProfile = null;
    notifyListeners();
  }

  // Reset password (Demo)
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // In demo mode, we just pretend to send a reset email
  }

  // Update user profile (Demo)
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      final UserProfile profile = updatedProfile.copyWith(
        lastUpdated: DateTime.now(),
      );
      
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}
