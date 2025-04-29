import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../services/face_api_service.dart';
import '../../core/constants.dart';
import '../../shared/widgets/show_snackbar.dart';

class FaceEnrollmentPage extends StatefulWidget {
  const FaceEnrollmentPage({super.key});

  @override
  State<FaceEnrollmentPage> createState() => _FaceEnrollmentPageState();
}

class _FaceEnrollmentPageState extends State<FaceEnrollmentPage> {
  Uint8List? _image;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _image = bytes);
    }
  }

  Future<void> _submitEnrollment() async {
    if (_image == null) {
      showSnackBar(context, "Please capture a face photo.", isError: true);
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      showSnackBar(context, "Not logged in.", isError: true);
      return;
    }

    setState(() => _loading = true);

    final result = await FaceApiService.enrollFace(_image!, userId);

    if (result != null && result['status'] == 'success') {
      showSnackBar(context, "Face enrolled successfully.");
      GoRouter.of(context).go('/home');
    } else {
      showSnackBar(context, "Face enrollment failed.", isError: true);
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      appBar: AppBar(
        title: const Text('Face Enrollment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Constants.accentColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('Take a clear photo of your face.',
                  style: Constants.labelStyle, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(_image!, height: 200),
                    )
                  : Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Constants.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.person, size: 80, color: Constants.accentColor),
                    ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Capture Face"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitEnrollment,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enroll Face'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
