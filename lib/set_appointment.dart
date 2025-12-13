import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class SetAppointmentPage extends StatefulWidget {
  const SetAppointmentPage({super.key});

  @override
  State<SetAppointmentPage> createState() => _SetAppointmentPageState();
}

class _SetAppointmentPageState extends State<SetAppointmentPage> {
  final _purposeController = TextEditingController();
  DateTime? selectedDate;
  int? selectedSlotHour;
  bool isSaving = false;

  // Theme colors
  static const Color primaryDeepPurple = Color(0xFFD69ADE);
  static const Color accentPurple = Color(0xFFD6C6D8);
  static const Color lightGreyBg = Color(0xFFF5F5F5);
  static const Color darkContrastPurple = Color(0xFF7B1FA2);

  // Clinic hours and configuration
  final clinicStartHour = 8;
  final clinicEndHour = 17;
  final lunchStartHour = 12;
  final maxAppointmentsPerSlot = 3;

  Map<int, bool> slotAvailability = {};

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  // ------------------ PICK DATE ------------------
  Future<void> _pickDate() async {
    DateTime initialDate = DateTime.now();
    // Skip to next valid clinic day if today is not M/W/F/Sat
    while (![
      DateTime.monday,
      DateTime.wednesday,
      DateTime.friday,
      DateTime.saturday
    ].contains(initialDate.weekday)) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
      selectableDayPredicate: (day) => [
        DateTime.monday,
        DateTime.wednesday,
        DateTime.friday,
        DateTime.saturday
      ].contains(day.weekday),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: primaryDeepPurple,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: primaryDeepPurple),
          ),
        ),
        child: child!,
      ),
    );

    if (date == null) return;

    if (!mounted) return;
    setState(() {
      selectedDate = date;
      selectedSlotHour = null;
    });

    await _generateSlotAvailability(date);
  }

  // ------------------ GENERATE TIME SLOTS ------------------
  Future<void> _generateSlotAvailability(DateTime date) async {
    slotAvailability.clear();
    final now = DateTime.now();

    for (int hour = clinicStartHour; hour <= clinicEndHour; hour++) {
      if (hour == lunchStartHour) {
        slotAvailability[hour] = false;
        continue;
      }

      // Disable past hours if selecting today
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day &&
          hour <= now.hour) {
        slotAvailability[hour] = false;
        continue;
      }

      final count = await _appointmentsCountInHour(date, hour);
      slotAvailability[hour] = count < maxAppointmentsPerSlot;
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<int> _appointmentsCountInHour(DateTime date, int hour) async {
    final startHour = DateTime(date.year, date.month, date.day, hour);
    final endHour = DateTime(date.year, date.month, date.day, hour, 59, 59);
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('appointmentdate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startHour))
        .where('appointmentdate',
            isLessThanOrEqualTo: Timestamp.fromDate(endHour))
        .get();
    return snapshot.docs.length;
  }

  String formatHourAMPM(int hour) {
    final dt = DateTime(0, 0, 0, hour);
    return DateFormat('h a').format(dt);
  }

  // ------------------ SAVE APPOINTMENT ------------------
  Future<void> _saveAppointment() async {
    if (selectedDate == null ||
        selectedSlotHour == null ||
        _purposeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    if (!mounted) return;
    setState(() => isSaving = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Generate Appointment Number globally
      final snap =
          await FirebaseFirestore.instance.collection('appointments').get();
      final count = snap.docs.length + 1;
      final appointmentNum = "SQ${count.toString().padLeft(3, '0')}";

      // Appointment slot datetime
      final appointmentDate = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedSlotHour!,
      );

      final slotStart = Timestamp.fromDate(appointmentDate);
      final slotEnd = Timestamp.fromDate(
          appointmentDate.add(const Duration(hours: 1, seconds: -1)));

      // Queue number per slot
      final slotSnap = await FirebaseFirestore.instance
          .collection('appointments')
          .where('appointmentdate', isGreaterThanOrEqualTo: slotStart)
          .where('appointmentdate', isLessThanOrEqualTo: slotEnd)
          .get();

      final newQueueNum = slotSnap.docs.length + 1;

      await FirebaseFirestore.instance.collection('appointments').add({
        "appointmentnum": appointmentNum,
        "appointmentdate": appointmentDate,
        "purpose": _purposeController.text.trim(),
        "status": "scheduled",
        "userId": userId,
        "createdAt": Timestamp.now(),
        "queuenum": newQueueNum,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Appointment set successfully!"),
          backgroundColor: primaryDeepPurple,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }

    if (!mounted) return;
    setState(() => isSaving = false);
  }

  // ------------------ BUILD UI ------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Set Appointment",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryDeepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel("Purpose of Visit"),
            const SizedBox(height: 10),
            _buildPurposeInput(),
            const SizedBox(height: 30),
            _buildSectionLabel("Select Date"),
            const SizedBox(height: 15),
            _buildDatePicker(),
            if (selectedDate != null) ...[
              const SizedBox(height: 30),
              _buildSectionLabel("Available Time Slots"),
              const SizedBox(height: 15),
              _buildTimeSlots(),
            ],
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkContrastPurple,
      ),
    );
  }

  Widget _buildPurposeInput() {
    return TextFormField(
      controller: _purposeController,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: "e.g., Annual Checkup, Consultation...",
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDeepPurple, width: 2),
        ),
        filled: true,
        fillColor: lightGreyBg,
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: lightGreyBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentPurple),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              selectedDate == null
                  ? "Tap 'Select' to choose a date (Mon, Wed, Fri, Sat)"
                  : DateFormat('EEEE, MMM d, yyyy').format(selectedDate!),
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: selectedDate == null
                    ? Colors.grey[600]
                    : darkContrastPurple,
                fontWeight:
                    selectedDate == null ? FontWeight.normal : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month, size: 20),
            label: const Text("Select"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryDeepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    const slotWidth = 170.0;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: slotAvailability.entries.map((entry) {
        final hour = entry.key;
        final isAvailable = entry.value;
        final isSelected = selectedSlotHour == hour;
        final slotText = formatHourAMPM(hour);
        final labelText = (hour == lunchStartHour)
            ? "Lunch Break"
            : "$slotText - ${formatHourAMPM(hour + 1)}";

        return SizedBox(
          width: slotWidth,
          child: ChoiceChip(
            label: Text(
              labelText,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isAvailable
                    ? (isSelected ? Colors.white : darkContrastPurple)
                    : Colors.black38,
              ),
            ),
            selected: isSelected,
            onSelected: isAvailable && hour != lunchStartHour
                ? (_) => setState(() => selectedSlotHour = hour)
                : null,
            selectedColor: primaryDeepPurple,
            backgroundColor: accentPurple.withOpacity(0.4),
            disabledColor: lightGreyBg.withOpacity(0.6),
            side: BorderSide(
                color: isSelected ? darkContrastPurple : accentPurple,
                width: 1.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSaving ? null : _saveAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDeepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Text("Submit"),
      ),
    );
  }
}
