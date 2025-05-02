import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/constants.dart';
import '../../shared/widgets/show_snackbar.dart';

class BiometricAuthPage extends StatelessWidget {
  const BiometricAuthPage({super.key});

  Future<void> _authenticate(BuildContext context) async {
    final auth = LocalAuthentication();

    try {
      final isAvailable = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();

      if (!isAvailable || !isDeviceSupported) {
        showSnackBar(context, "Biometric auth not supported", isError: true);
        return;
      }

      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Authenticate with Face ID / Fingerprint',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.emailVerified) {
          GoRouter.of(context).go('/home');
        } else if (user != null && !user.emailVerified) {
          showSnackBar(context, "Verify your email before using biometrics", isError: true);
        } else {
          showSnackBar(context, "No user session found. Please login once.", isError: true);
        }
      } else {
        showSnackBar(context, "Authentication failed", isError: true);
      }
    } catch (e) {
      showSnackBar(context, "Error: $e", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      appBar: AppBar(
        title: const Text('Biometric Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Constants.accentColor,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.fingerprint),
          label: const Text("Authenticate"),
          onPressed: () => _authenticate(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.accentColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
