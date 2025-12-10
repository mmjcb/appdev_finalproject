import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'appointment_delete.dart';
import 'appointment_edit.dart';
import 'set_appointment.dart';
import 'appointment_view.dart'; // <- Import modal

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  // FORMAT DATE (handles Timestamp, String, DateTime)
  String formatDateTime(dynamic dateTime) {
    if (dateTime == null) return "Unknown Date";
    try {
      DateTime dt;
      if (dateTime is Timestamp) {
        dt = dateTime.toDate();
      } else if (dateTime is String) {
        dt = DateTime.tryParse(dateTime) ?? DateTime.now();
      } else if (dateTime is DateTime) {
        dt = dateTime;
      } else {
        return dateTime.toString();
      }
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dt);
    } catch (e) {
      return dateTime.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "User not logged in",
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),
              _setAppointmentButton(context),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Scheduled Appointments",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _scheduledAppointments(user.uid, context),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Appointment History",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "See More",
                            style: GoogleFonts.poppins(
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _historyAppointments(user.uid),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(162, 234, 189, 230), Color(0xFFD69ADE)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/skipq-logo.png', height: 42),
          Row(
            children: const [
              Icon(Icons.notifications_none, color: Colors.white),
              SizedBox(width: 10),
              Icon(Icons.settings, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- SET APPOINTMENT BUTTON ----------------
  Widget _setAppointmentButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SetAppointmentPage()),
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFD69ADE), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: const Icon(Icons.add_circle_outline, color: Color(0xFFD69ADE)),
          label: Text(
            'Set an Appointment',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD69ADE),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SCHEDULED APPOINTMENTS ----------------
  Widget _scheduledAppointments(String uid, BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: uid)
          .where('status', isEqualTo: 'scheduled')
          .snapshots(),
      builder: (contextStream, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "No upcoming appointments",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _upcomingCard(
              context: context,
              title: data['purpose'] ?? '',
              time: formatDateTime(data['appointmentdate']),
              code: data['appointmentnum'] ?? '',
              queue: "${data['queuenum']}",
              docId: doc.id,
              data: data,
            );
          }).toList(),
        );
      },
    );
  }

  // ---------------- HISTORY APPOINTMENTS ----------------
  Widget _historyAppointments(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .snapshots(),
      builder: (contextStream, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "No past appointments",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _historyItem(
              title: data['purpose'] ?? '',
              date: formatDateTime(data['appointmentdate']),
            );
          }).toList(),
        );
      },
    );
  }

  // ---------------- UPCOMING CARD ----------------
  Widget _upcomingCard({
    required BuildContext context,
    required String title,
    required String time,
    required String code,
    required String queue,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 4),
                    Text(time, style: GoogleFonts.poppins(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.confirmation_number, size: 18),
                    const SizedBox(width: 4),
                    Text(code, style: GoogleFonts.poppins(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AppointmentEditPage(docId: docId, data: data),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Edit", style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        AppointmentDelete.deleteAppointment(
                            context: context, docId: docId);
                      },
                      icon:
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                      label: const Text("Delete",
                          style: TextStyle(fontSize: 12, color: Colors.red)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Show dialog modal instead of bottom sheet
                        AppointmentViewModal.show(context, docId);
                      },
                      icon: const Icon(Icons.remove_red_eye, size: 16),
                      label: const Text("View", style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text("Queue Number",
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.black87)),
                Text(queue,
                    style: GoogleFonts.poppins(
                        fontSize: 60,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HISTORY ITEM ----------------
  Widget _historyItem({required String title, required String date}) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.purple),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 15)),
                  Text(date,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 20, thickness: 1),
      ],
    );
  }
}
