import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';

class AttendanceHistoryPage extends StatelessWidget {
  const AttendanceHistoryPage({super.key});

  Stream<QuerySnapshot> _fetchAttendanceRecords() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection(Constants.attendanceCollection)
        .doc(userId)
        .collection('records')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      appBar: AppBar(
        title: const Text("My Attendance"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Constants.accentColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchAttendanceRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No attendance records found.', style: Constants.labelStyle),
            );
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final date = record['date'] ?? '';
              final time = record['time'] ?? '';
              final confidence = record['confidence']?.toStringAsFixed(2) ?? '0.0';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: Constants.accentColor),
                        const SizedBox(width: 8),
                        Text(date, style: Constants.labelStyle),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20, color: Constants.accentColor),
                        const SizedBox(width: 8),
                        Text(time, style: Constants.labelStyle),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.verified_user, size: 20, color: Constants.accentColor),
                        const SizedBox(width: 8),
                        Text("Confidence: $confidence%", style: Constants.labelStyle),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
