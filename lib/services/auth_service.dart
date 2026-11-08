import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;

  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;

  UserModel? get currentUser => _currentUser;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    initAuth();
  }

  // --------------------------------------------------
  // INITIALIZE FIREBASE AUTHENTICATION
  // --------------------------------------------------

  Future<void> initAuth() async {
    if (_authSubscription != null) return;

    _authSubscription = _firebaseAuth.authStateChanges().listen(
      (firebaseUser) async {
        _isLoading = true;
        notifyListeners();

        try {
          if (firebaseUser == null) {
            _currentUser = null;
          } else {
            _currentUser = await _loadUserProfile(firebaseUser);
          }
        } catch (e) {
          _currentUser = null;
          _errorMessage = 'Unable to load your profile. Please try again.';
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (error) {
        _currentUser = null;
        _isLoading = false;
        _errorMessage = 'Authentication initialization failed.';
        notifyListeners();
      },
    );
  }

  // --------------------------------------------------
  // LOAD USER PROFILE FROM FIRESTORE
  // --------------------------------------------------

  Future<UserModel> _loadUserProfile(User firebaseUser) async {
    final document = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (document.exists && document.data() != null) {
      return UserModel.fromFirestore(firebaseUser.uid, document.data()!);
    }

    // Fallback for an authenticated account without a profile.
    // This does NOT grant provider or administrator privileges.
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: firebaseUser.displayName ?? '',
      nationalId: '',
      dob: '',
      homeVillage: '',
      phone: '',
      role: 'citizen',
      status: 'active',
      identityVerificationStatus: 'unverified',
    );
  }

  // --------------------------------------------------
  // LOGIN
  // --------------------------------------------------

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase did not return a user account.');
      }

      _currentUser = await _loadUserProfile(firebaseUser);

      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
    } on FirebaseException catch (e) {
      _errorMessage = e.code == 'permission-denied'
          ? 'You are signed in, but your profile cannot be accessed. Please check the Firestore security rules.'
          : 'Unable to retrieve your profile. Please try again.';
    } catch (e) {
      _errorMessage = 'An unexpected login error occurred.';
    }

    _isLoading = false;
    notifyListeners();

    return false;
  }

  // --------------------------------------------------
  // REGISTER
  // --------------------------------------------------

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String nationalId,
    required String dob,
    required String homeVillage,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    User? newlyCreatedUser;

    try {
      // Step 1: Create Firebase Authentication account.
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Could not create the Firebase account.');
      }

      newlyCreatedUser = firebaseUser;

      // Step 2: Prepare citizen profile.
      final user = UserModel(
        uid: firebaseUser.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        nationalId: nationalId.trim(),
        dob: dob.trim(),
        homeVillage: homeVillage.trim(),
        phone: phone.trim(),
        role: 'citizen',
        status: 'active',
        identityVerificationStatus: 'unverified',
      );

      // Step 3: Save profile under the Firebase UID.
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(user.toFirestore());

      // Step 4: Update local application state.
      _currentUser = user;

      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
    } on FirebaseException catch (e) {
      _errorMessage = e.code == 'permission-denied'
          ? 'Your account was created, but Firestore rejected the profile. Please check your security rules and try again.'
          : 'Unable to save your citizen profile. Please try again.';
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
    }

    // Roll back a newly created account if its profile could not be saved.
    if (newlyCreatedUser != null) {
      try {
        await newlyCreatedUser.delete();
      } catch (_) {
        // If deletion fails, the account may need manual cleanup.
      }
    }

    _currentUser = null;
    _isLoading = false;
    notifyListeners();

    return false;
  }

  // --------------------------------------------------
  // REFRESH PROFILE
  // --------------------------------------------------

  Future<void> refreshProfile() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    try {
      _currentUser = await _loadUserProfile(firebaseUser);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Unable to refresh your profile.';
    }

    notifyListeners();
  }

  // --------------------------------------------------
  // FORGOT PASSWORD
  // --------------------------------------------------

  Future<bool> sendPasswordResetEmail(String email) async {
    _errorMessage = null;

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'Unable to send the password reset email.';
      return false;
    }
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();

      _currentUser = null;
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Unable to log out. Please try again.';
      notifyListeners();
    }
  }

  // --------------------------------------------------
  // FIREBASE ERROR MESSAGES
  // --------------------------------------------------

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-not-found':
        return 'No account exists with this email address.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';

      case 'email-already-in-use':
        return 'An account already exists with this email address.';

      case 'weak-password':
        return 'Your password is too weak. Please choose a stronger password.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';

      case 'operation-not-allowed':
        return 'Email and password authentication is not enabled.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
