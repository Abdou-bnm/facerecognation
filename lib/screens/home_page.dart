import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    GoRouter.of(context).go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Guest';

    return Scaffold(
      backgroundColor: Constants.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Home', style: TextStyle(color: Constants.accentColor)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Constants.accentColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: Constants.accentColor.withOpacity(0.1),
                child: const Icon(Icons.person, size: 40, color: Constants.accentColor),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome, $email!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Constants.accentColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your face attendance easily',
                style: Constants.labelStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.9,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _HomeButton(
                    label: 'Scan Face',
                    icon: Icons.camera_alt_outlined,
                    onTap: () => GoRouter.of(context).push('/face-scan'),
                  ),
                  _HomeButton(
                    label: 'My History',
                    icon: Icons.history,
                    onTap: () => GoRouter.of(context).push('/attendance-history'),
                  ),
                  _HomeButton(
                    label: 'Profile',
                    icon: Icons.person_outline,
                    onTap: () {}, // Profile screen (optional to build)
                  ),
                  _HomeButton(
                    label: 'Face Enrollment',
                    icon: Icons.add_a_photo_outlined,
                    onTap: () => GoRouter.of(context).push('/face-enroll'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Constants.accentColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Constants.accentColor),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Constants.accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
