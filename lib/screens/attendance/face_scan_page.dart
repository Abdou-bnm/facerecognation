import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/face_api_service.dart';
import '../../core/constants.dart';
import '../../shared/widgets/show_snackbar.dart';

class FaceScanPage extends StatefulWidget {
  const FaceScanPage({super.key});

  @override
  State<FaceScanPage> createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<FaceScanPage> {
  Uint8List? _image;
  double? _confidence;
  bool _loading = false;

  Future<void> _pickFace() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _image = bytes);
    }
  }

  Future<void> _scanFace() async {
    if (_image == null) {
      showSnackBar(context, "Please capture your face first.", isError: true);
      return;
    }

    setState(() {
      _loading = true;
      _confidence = null;
    });

    final result = await FaceApiService.searchFace(_image!);

    if (result != null && result['status'] == 'success') {
      final confidence = double.tryParse(result['confidence']?.toString() ?? '0');
      setState(() => _confidence = confidence ?? 0);

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final now = DateTime.now();
        final date = DateFormat('yyyy-MM-dd').format(now);
        final time = DateFormat('HH:mm').format(now);

        await FirebaseFirestore.instance
            .collection(Constants.attendanceCollection)
            .doc(userId)
            .collection('records')
            .add({
          'date': date,
          'time': time,
          'confidence': confidence,
          'timestamp': FieldValue.serverTimestamp(),
        });

        showSnackBar(context, "Attendance marked! Confidence: ${confidence?.toStringAsFixed(2)}%");
      } else {
        showSnackBar(context, "User not logged in.", isError: true);
      }
    } else {
      showSnackBar(context, "Face not recognized.", isError: true);
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      appBar: AppBar(
        title: const Text("Face Attendance"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Constants.accentColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text("Scan your face to mark attendance.",
                  style: Constants.labelStyle, textAlign: TextAlign.center),
              const SizedBox(height: 24),
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
                      child: const Icon(Icons.face, size: 80, color: Constants.accentColor),
                    ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickFace,
                icon: const Icon(Icons.camera),
                label: const Text("Capture Face"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _scanFace,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Scan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              if (_confidence != null)
                Text("Match Confidence: ${_confidence!.toStringAsFixed(2)}%",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Constants.accentColor)),
            ],
          ),
        ),
      ),
    );
  }
}
