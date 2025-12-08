import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentEditPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const AppointmentEditPage({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<AppointmentEditPage> createState() => _AppointmentEditPageState();
}

class _AppointmentEditPageState extends State<AppointmentEditPage> {
  final _purposeController = TextEditingController();
  DateTime? selectedDate;
  int? selectedSlotHour;
  bool isSaving = false;

  final clinicStartHour = 8;
  final clinicEndHour = 17;
  final lunchHour = 12;
  final maxAppointmentsPerSlot = 3;

  Map<int, bool> slotAvailability = {}; // hour -> available or not

  @override
  void initState() {
    super.initState();
    _purposeController.text = widget.data['purpose'] ?? "";

    final ts = widget.data['appointmentdate'] as Timestamp;
    final dt = ts.toDate();
    selectedDate = DateTime(dt.year, dt.month, dt.day);
    selectedSlotHour = dt.hour;

    if (selectedDate != null) _generateSlotAvailability(selectedDate!);
  }

  // ----------------- GENERATE SLOT AVAILABILITY -----------------
  Future<void> _generateSlotAvailability(DateTime date) async {
    slotAvailability.clear();

    for (int hour = clinicStartHour; hour <= clinicEndHour; hour++) {
      if (hour == lunchHour) {
        slotAvailability[hour] = false; // lunch break
        continue;
      }

      final count = await _appointmentsCountInHour(date, hour);
      // Allow current appointment slot even if full
      final isCurrentSlot = selectedSlotHour == hour &&
          date.year == selectedDate!.year &&
          date.month == selectedDate!.month &&
          date.day == selectedDate!.day;
      slotAvailability[hour] = count < maxAppointmentsPerSlot || isCurrentSlot;
    }

    setState(() {});
  }

  // ----------------- COUNT APPOINTMENTS IN HOUR -----------------
  Future<int> _appointmentsCountInHour(DateTime date, int hour) async {
    final startHour = DateTime(date.year, date.month, date.day, hour, 0, 0);
    final endHour = DateTime(date.year, date.month, date.day, hour, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('appointmentdate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startHour))
        .where('appointmentdate',
            isLessThanOrEqualTo: Timestamp.fromDate(endHour))
        .get();

    // Exclude the current appointment being edited
    final filtered = snapshot.docs.where((doc) => doc.id != widget.docId);

    return filtered.length;
  }

  // ----------------- PICK DATE -----------------
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
      selectableDayPredicate: (day) => day.weekday >= 1 && day.weekday <= 5,
    );

    if (date == null) return;

    selectedDate = date;
    selectedSlotHour = null;
    await _generateSlotAvailability(date);
  }

  // ----------------- FORMAT HOUR TO AM/PM -----------------
  String formatHourAMPM(int hour) {
    final dt = DateTime(0, 0, 0, hour);
    final formatter = DateFormat.j(); // 12-hour with AM/PM
    return formatter.format(dt);
  }

  // ----------------- SAVE CHANGES -----------------
  Future<void> _saveChanges() async {
    if (selectedDate == null ||
        selectedSlotHour == null ||
        _purposeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final appointmentDate = DateTime(selectedDate!.year, selectedDate!.month,
          selectedDate!.day, selectedSlotHour!, 0);

      await FirebaseFirestore.instance
          .collection("appointments")
          .doc(widget.docId)
          .update({
        "purpose": _purposeController.text.trim(),
        "appointmentdate": appointmentDate,
      });

      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Appointment")),
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
                  child: Text(selectedDate == null
                      ? "No date selected"
                      : "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}"),
                ),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text("Pick Date"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (selectedDate != null)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: slotAvailability.entries.map((entry) {
                  final hour = entry.key;
                  final available = entry.value;
                  final isSelected = selectedSlotHour == hour;

                  // Display as "8:00 AM - 8:59 AM"
                  final slotText =
                      "${formatHourAMPM(hour)} - ${formatHourAMPM(hour).replaceAll(RegExp(r'AM|PM'), '')}${hour < 12 ? ' AM' : ' PM'}";

                  return ChoiceChip(
                    label: Text(slotText),
                    selected: isSelected,
                    onSelected: available
                        ? (_) {
                            setState(() {
                              selectedSlotHour = hour;
                            });
                          }
                        : null,
                    selectedColor: Colors.purple[200],
                    backgroundColor:
                        available ? Colors.grey[200] : Colors.grey[400],
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedSlotHour == null || isSaving)
                    ? null
                    : _saveChanges,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
