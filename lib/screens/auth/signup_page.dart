import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../shared/widgets/show_snackbar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  Uint8List? _profileImage;
  String? _gender;

  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _profileImage = bytes);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _gender == null) {
      showSnackBar(context, "Fill all fields correctly", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      final uid = FirebaseAuth.instance.currentUser?.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'full_name': _fullNameCtrl.text.trim(),
        'phone': '+213${_phoneCtrl.text.trim()}',
        'gender': _gender,
      });

      showSnackBar(context, "Account created! Verify your email.");

      GoRouter.of(context).pushReplacement('/verify-email');
    } catch (e) {
      showSnackBar(context, e.toString(), isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Constants.accentColor.withOpacity(0.1),
                      backgroundImage: _profileImage != null ? MemoryImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? const Icon(Icons.add_a_photo, color: Constants.accentColor)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _fullNameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (val) => val!.contains('@') ? null : 'Invalid Email',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('+213'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneCtrl,
                          decoration: const InputDecoration(labelText: 'Phone Number'),
                          validator: (val) => val!.length >= 8 ? null : 'Invalid number',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Male'),
                        selected: _gender == 'Male',
                        onSelected: (_) => setState(() => _gender = 'Male'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Female'),
                        selected: _gender == 'Female',
                        onSelected: (_) => setState(() => _gender = 'Female'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (val) => val!.length >= 6 ? null : 'Min 6 characters',
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.accentColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading ? const CircularProgressIndicator() : const Text('Sign Up'),
                  ),
                  TextButton(
                    onPressed: () => GoRouter.of(context).go('/login'),
                    child: const Text('Already have an account? Login', style: TextStyle(color: Constants.accentColor)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
