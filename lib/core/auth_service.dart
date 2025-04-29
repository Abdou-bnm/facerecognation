import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up with email/password
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String registrationNumber,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

    // Send email verification
    await userCredential.user?.sendEmailVerification();

    // Save user info to Firestore
    await _firestore.collection(Constants.usersCollection).doc(userCredential.user?.uid).set({
      'first_name': firstName,
      'last_name': lastName,
      'registration_number': registrationNumber,
      'email': email,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Sign In with email/password
  Future<void> login({required String email, required String password}) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (!credential.user!.emailVerified) {
      await _auth.signOut();
      throw Exception('Email not verified. Please verify your email.');
    }
  }

  // Forgot Password
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In canceled.');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // Save user if first time
    if (userCredential.additionalUserInfo?.isNewUser ?? false) {
      final user = userCredential.user!;
      await _firestore.collection(Constants.usersCollection).doc(user.uid).set({
        'first_name': user.displayName?.split(' ').first ?? '',
        'last_name': user.displayName?.split(' ').skip(1).join(' ') ?? '',
        'email': user.email,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
