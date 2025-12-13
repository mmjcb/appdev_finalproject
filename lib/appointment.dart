import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'appointment_edit.dart';
import 'set_appointment.dart';
import 'appointment_view.dart';

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
                    _historyAppointments(user.uid, context),
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
            Navigator.of(context, rootNavigator: false).push(
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

        // Sort by queuenum ascending
        docs.sort((a, b) {
          final qA = (a['queuenum'] ?? 999) as int;
          final qB = (b['queuenum'] ?? 999) as int;
          return qA.compareTo(qB);
        });

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _appointmentCard(
              context: context,
              title: data['purpose'] ?? '',
              date: formatDateTime(data['appointmentdate']),
              code: data['appointmentnum'] ?? '',
              queue: "${data['queuenum'] ?? "-"}",
              docId: doc.id,
              data: data,
            );
          }).toList(),
        );
      },
    );
  }

  // ---------------- HISTORY APPOINTMENTS ----------------
  Widget _historyAppointments(String uid, BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('archives')
          .where('userId', isEqualTo: uid)
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

        // Sort by archivedAt descending
        docs.sort((a, b) {
          final tsA = a['archivedAt'] as Timestamp?;
          final tsB = b['archivedAt'] as Timestamp?;
          return (tsB ?? Timestamp(0, 0)).compareTo(tsA ?? Timestamp(0, 0));
        });

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _historyItem(
              title: data['purpose'] ?? '',
              date: formatDateTime(data['appointmentdate']),
              status: data['status'] ?? 'deleted',
            );
          }).toList(),
        );
      },
    );
  }

  // ---------------- APPOINTMENT CARD ----------------
  Widget _appointmentCard({
    required BuildContext context,
    required String title,
    required String date,
    required String code,
    required String queue,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    final user = FirebaseAuth.instance.currentUser;

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
                    Text(date, style: GoogleFonts.poppins(fontSize: 14)),
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
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AppointmentEditPage(docId: docId, data: data),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: "Edit",
                    ),
                    IconButton(
                      onPressed: () async {
                        if (user == null) return;
                        await FirebaseFirestore.instance
                            .collection('archives')
                            .add({
                          ...data,
                          'userId': user.uid,
                          'status': 'deleted',
                          'archivedAt': Timestamp.now(),
                        });
                        await FirebaseFirestore.instance
                            .collection('appointments')
                            .doc(docId)
                            .delete();
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: "Archive/Delete",
                    ),
                    IconButton(
                      onPressed: () {
                        AppointmentViewModal.show(
                            Navigator.of(context, rootNavigator: false).context,
                            docId);
                      },
                      icon: const Icon(Icons.remove_red_eye,
                          color: Colors.purple),
                      tooltip: "View",
                    ),
                    IconButton(
                      onPressed: () async {
                        if (user == null) return;
                        await FirebaseFirestore.instance
                            .collection('archives')
                            .add({
                          ...data,
                          'userId': user.uid,
                          'status': 'completed',
                          'archivedAt': Timestamp.now(),
                        });
                        await FirebaseFirestore.instance
                            .collection('appointments')
                            .doc(docId)
                            .delete();
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: "Complete",
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Queue",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  child: Text(
                    queue,
                    style: GoogleFonts.poppins(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HISTORY ITEM ----------------
  Widget _historyItem({
    required String title,
    required String date,
    required String status,
  }) {
    Color badgeColor =
        status == 'completed' ? Colors.green : Colors.red;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.history, color: Colors.purple),
            const SizedBox(width: 8),

            // LEFT SIDE (Title + Date)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT SIDE (Status Badge)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 20, thickness: 1),
      ],
    );
  }
}
