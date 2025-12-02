import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetAppointmentPage extends StatefulWidget {
  const SetAppointmentPage({super.key});

  @override
  State<SetAppointmentPage> createState() => _SetAppointmentPageState();
}

class _SetAppointmentPageState extends State<SetAppointmentPage> {
  final _purposeController = TextEditingController();
  DateTime? selectedDateTime;
  bool isSaving = false;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveAppointment() async {
    if (selectedDateTime == null || _purposeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Generate Appointment Number
      final snap = await FirebaseFirestore.instance.collection('appointments').get();
      final count = snap.docs.length + 1;
      final appointmentNum = "SQ${count.toString().padLeft(3, '0')}";

      // --- NEW QUEUE LOGIC ---
      final lastQueueSnap = await FirebaseFirestore.instance
          .collection('appointments')
          .orderBy('queuenum', descending: true)
          .limit(1)
          .get();

      final lastQueueNum = lastQueueSnap.docs.isEmpty
          ? 0
          : lastQueueSnap.docs.first['queuenum'] ?? 0;

      final newQueueNum = lastQueueNum + 1;

      await FirebaseFirestore.instance.collection('appointments').add({
        "appointmentnum": appointmentNum,
        "appointmentdate": selectedDateTime,
        "purpose": _purposeController.text.trim(),
        "status": "scheduled",
        "userId": userId,
        "createdAt": Timestamp.now(),
        "queuenum": newQueueNum, // permanent queue number
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error saving appointment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: "Purpose of Appointment",
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(selectedDateTime == null
                      ? "No date selected"
                      : "${selectedDateTime!.month}/${selectedDateTime!.day}/${selectedDateTime!.year} "
                        "${selectedDateTime!.hour.toString().padLeft(2, '0')}:"
                        "${selectedDateTime!.minute.toString().padLeft(2, '0')}"),
                ),
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: const Text("Pick Date & Time"),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: isSaving ? null : _saveAppointment,
              child: isSaving
                  ? const CircularProgressIndicator()
                  : const Text("Save Appointment"),
            )
          ],
        ),
      ),
    );
  }
}
