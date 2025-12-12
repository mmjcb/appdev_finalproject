import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentDelete {
  /// Deletes an appointment from Firestore with optional confirmation dialog
  static Future<void> deleteAppointment({
    required BuildContext context,
    required String docId,
    bool showConfirmation = true,
  }) async {
    // Show confirmation dialog
    if (showConfirmation) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete Appointment"),
          content:
              const Text("Are you sure you want to delete this appointment?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return; // User canceled
    }

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete appointment: $e")),
      );
    }
  }
}
