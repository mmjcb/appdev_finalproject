import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentDelete {
  /// Soft-deletes an appointment by updating its status to 'deleted'
  /// and recording the deletion time.
  static Future<void> deleteAppointment({
    required BuildContext context,
    required String docId,
    bool showConfirmation = true,
  }) async {
    final rootContext = ScaffoldMessenger.maybeOf(context)?.context ?? context;

    if (showConfirmation) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text("Delete Appointment"),
          content: const Text(
              "Are you sure you want to delete this appointment? It will still appear in history."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .update({'status': 'deleted', 'deletedAt': Timestamp.now()});

      if (!rootContext.mounted) return;

      ScaffoldMessenger.of(rootContext).showSnackBar(
        const SnackBar(content: Text("Appointment deleted successfully")),
      );
    } catch (e) {
      if (!rootContext.mounted) return;

      ScaffoldMessenger.of(rootContext).showSnackBar(
        SnackBar(content: Text("Failed to delete appointment: $e")),
      );
    }
  }

  /// Optional: Restore a deleted appointment back to active
  static Future<void> restoreAppointment({
    required BuildContext context,
    required String docId,
  }) async {
    final rootContext = ScaffoldMessenger.maybeOf(context)?.context ?? context;

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .update({'status': 'scheduled', 'deletedAt': null});

      if (!rootContext.mounted) return;

      ScaffoldMessenger.of(rootContext).showSnackBar(
        const SnackBar(content: Text("Appointment restored successfully")),
      );
    } catch (e) {
      if (!rootContext.mounted) return;

      ScaffoldMessenger.of(rootContext).showSnackBar(
        SnackBar(content: Text("Failed to restore appointment: $e")),
      );
    }
  }
}
