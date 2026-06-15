import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_session.dart';

class AuthResult {
  const AuthResult.success(this.session) : errorMessage = null;
  const AuthResult.failure(this.errorMessage) : session = null;

  final UserSession? session;
  final String? errorMessage;

  bool get isSuccess => session != null;
}

class AuthRepository {
  AuthRepository();

  bool _firebaseReady = false;
  bool _googleReady = false;

  bool get firebaseReady => _firebaseReady;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _firebaseReady = true;
    } catch (error) {
      debugPrint('Firebase is not configured yet: $error');
      _firebaseReady = false;
    }

    try {
      await GoogleSignIn.instance.initialize();
      _googleReady = true;
    } catch (error) {
      debugPrint('Google Sign-In is not configured yet: $error');
      _googleReady = false;
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    if (!_firebaseReady) {
      return const AuthResult.failure(
        'Firebase is not configured yet. Add Firebase options/config files first.',
      );
    }

    if (!_googleReady) {
      return const AuthResult.failure(
        'Google Sign-In is not configured yet for this platform.',
      );
    }

    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        return const AuthResult.failure(
          'Google sign-in did not return a user.',
        );
      }

      final session = UserSession(
        id: user.uid,
        displayName: user.displayName ?? googleUser.displayName ?? 'Player',
        email: user.email ?? googleUser.email,
        avatarColorValue: 0xFF0F8B6B,
        isGuest: false,
      );
      await _saveUserProfile(session);
      return AuthResult.success(session);
    } catch (error) {
      return AuthResult.failure('Google sign-in failed: $error');
    }
  }

  Future<void> signOut() async {
    try {
      if (_googleReady) {
        await GoogleSignIn.instance.signOut();
      }
      if (_firebaseReady) {
        await FirebaseAuth.instance.signOut();
      }
    } catch (error) {
      debugPrint('Sign out failed: $error');
    }
  }

  Future<void> savePlayerGroup(PlayerGroupPreset group) async {
    if (!_firebaseReady || group.ownerUserId == 'guest') {
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(group.ownerUserId)
        .collection('playerGroups')
        .doc(group.id)
        .set({
          'name': group.name,
          'playerNames': group.playerNames,
          'ownerUserId': group.ownerUserId,
          'isShared': group.isShared,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> sharePlayerGroup(PlayerGroupPreset group) async {
    if (!_firebaseReady || group.ownerUserId == 'guest') {
      return;
    }

    await FirebaseFirestore.instance
        .collection('sharedPlayerGroups')
        .doc(group.id)
        .set({
          'name': group.name,
          'playerNames': group.playerNames,
          'ownerUserId': group.ownerUserId,
          'isShared': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> followUser({
    required String ownerUserId,
    required FollowedUser followedUser,
  }) async {
    if (!_firebaseReady || ownerUserId == 'guest') {
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(ownerUserId)
        .collection('following')
        .doc(followedUser.id)
        .set({
          'displayName': followedUser.displayName,
          'handle': followedUser.handle,
          'followedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _saveUserProfile(UserSession session) async {
    if (!_firebaseReady || session.isGuest) {
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(session.id).set({
      'displayName': session.displayName,
      'email': session.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
