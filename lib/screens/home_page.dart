import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';
import '../shared/widgets/show_snackbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _biometricEnabled = false;
  bool _loading = true;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    try {
      final enabled = await AuthService().isBiometricEnabled();
      setState(() {
        _biometricEnabled = enabled;
        _loading = false;
      });
    } catch (e) {
      showSnackBar(context, 'Failed to load settings', isError: true);
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    setState(() => _biometricEnabled = value);
    await AuthService().setBiometricPreference(value);
    showSnackBar(
      context,
      value ? "Biometric login enabled" : "Biometric login disabled",
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    GoRouter.of(context).go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? 'Guest';

    return Scaffold(
      backgroundColor: Constants.primaryColor,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Constants.accentColor,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Constants.accentColor.withOpacity(0.1),
                      child: const Icon(Icons.person,
                          size: 40, color: Constants.accentColor),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome, $email!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Constants.accentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Manage your settings below',
                      style: Constants.labelStyle,
                    ),
                    const SizedBox(height: 30),

                    // ✅ Biometric toggle
                    SwitchListTile.adaptive(
                      value: _biometricEnabled,
                      onChanged: _toggleBiometric,
                      title: const Text("Use biometric login"),
                      subtitle: const Text("Enable Face ID / Fingerprint"),
                      activeColor: Constants.accentColor,
                    ),

                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () => GoRouter.of(context).go('/biometric-auth'),
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Test Biometric Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.accentColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
