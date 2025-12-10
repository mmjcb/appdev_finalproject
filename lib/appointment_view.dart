import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentViewModal extends StatelessWidget {
  final String docId;

  const AppointmentViewModal({super.key, required this.docId});

  String formatDateTime(dynamic dateTime) {
    try {
      if (dateTime is DateTime) {
        return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
      }
      if (dateTime is String) {
        return DateFormat('MMM dd, yyyy - hh:mm a')
            .format(DateTime.parse(dateTime));
      }
      if (dateTime is Timestamp) {
        return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime.toDate());
      }
      return "Unknown";
    } catch (e) {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("appointments")
          .doc(docId)
          .get(),
      builder: (context, appointmentSnapshot) {
        if (appointmentSnapshot.connectionState == ConnectionState.waiting) {
          return _loading();
        }

        if (!appointmentSnapshot.hasData || !appointmentSnapshot.data!.exists) {
          return _error("Appointment not found.");
        }

        final appointmentData =
            appointmentSnapshot.data!.data() as Map<String, dynamic>;
        final userId = appointmentData['userId'];

        // Fetch user data
        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection("users").doc(userId).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return _loading();
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return _error("User not found.");
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final firstName = userData['firstName'] ?? 'User';

            return Container(
              width: 300, // fixed width
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F0FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _modalContent(context, appointmentData, firstName),
            );
          },
        );
      },
    );
  }

  Widget _loading() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: const CircularProgressIndicator(color: Colors.purple),
      ),
    );
  }

  Widget _error(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Text(message,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
      ),
    );
  }

  Widget _modalContent(BuildContext context,
      Map<String, dynamic> appointmentData, String firstName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Hi, $firstName!",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.purple[900],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Your appointment number is",
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFB66CCE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            appointmentData["appointmentnum"] ?? "N/A",
            style: GoogleFonts.poppins(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Image.asset(
          "assets/bunny-home.png",
          height: 80,
        ),
        const SizedBox(height: 6),
        Text(
          "Your position in queue",
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        Text(
          "${appointmentData['queuenum'] ?? '0'}",
          style: GoogleFonts.poppins(
            fontSize: 48,
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Your appointment is scheduled on:\n"
          "${formatDateTime(appointmentData['appointmentdate'])}",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 10),
        ),
      ],
    );
  }

  // -------------------- Show Dialog --------------------
  static Future<void> show(BuildContext context, String docId) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(), // close when tap outside
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // prevent closing when tap inside
              child: AppointmentViewModal(docId: docId),
            ),
          ),
        ),
      ),
    );
  }
}
