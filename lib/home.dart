import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'set_appointment.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String firstName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            firstName = doc.data()?['firstName'] ?? "User";
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  String formatDateTime(dynamic dateTime) {
    if (dateTime == null) return "Unknown Date";
    try {
      DateTime dt;
      if (dateTime is Timestamp) {
        dt = dateTime.toDate();
      } else if (dateTime is String) {
        dt = DateTime.parse(dateTime);
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(162, 234, 189, 230),
                      Color(0xFFD69ADE),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/skipq-logo.png', height: 42),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, $firstName!",
                                style: GoogleFonts.poppins(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "What are we doing today?",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SetAppointmentPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "Set an Appointment",
                                  style: GoogleFonts.poppins(
                                    color: Colors.purple[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset('assets/bunny-home.png', height: 200),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      "Scheduled Appointments",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _scheduledAppointments(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Appointments",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
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
                    _recentAppointments(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Scheduled appointments
  Widget _scheduledAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .snapshots(), // filter by user only
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "No scheduled appointments yet.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Filter scheduled appointments in Dart
        final scheduledDocs = snapshot.data!.docs
            .map((d) => d.data() as Map<String, dynamic>)
            .where((data) => data['status'] == 'scheduled')
            .toList();

        if (scheduledDocs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "No scheduled appointments yet.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Sort by appointment date
        scheduledDocs.sort((a, b) {
          final aDate = a['appointmentdate'] is Timestamp
              ? (a['appointmentdate'] as Timestamp).toDate()
              : DateTime.tryParse(a['appointmentdate'].toString()) ??
                  DateTime.now();
          final bDate = b['appointmentdate'] is Timestamp
              ? (b['appointmentdate'] as Timestamp).toDate()
              : DateTime.tryParse(b['appointmentdate'].toString()) ??
                  DateTime.now();
          return aDate.compareTo(bDate);
        });

        return Column(
          children: scheduledDocs.map((data) {
            return _appointmentCard(
              formatDateTime(data['appointmentdate']),
              data['queuenum']?.toString() ?? "-",
            );
          }).toList(),
        );
      },
    );
  }

  // Recent/completed appointments
  Widget _recentAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .snapshots(), // filter by user only
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "No appointment history yet.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Filter completed appointments in Dart
        final completedDocs = snapshot.data!.docs
            .map((d) => d.data() as Map<String, dynamic>)
            .where((data) => data['status'] == 'completed')
            .toList();

        if (completedDocs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "No appointment history yet.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Sort descending by appointment date
        completedDocs.sort((a, b) {
          final aDate = a['appointmentdate'] is Timestamp
              ? (a['appointmentdate'] as Timestamp).toDate()
              : DateTime.tryParse(a['appointmentdate'].toString()) ??
                  DateTime.now();
          final bDate = b['appointmentdate'] is Timestamp
              ? (b['appointmentdate'] as Timestamp).toDate()
              : DateTime.tryParse(b['appointmentdate'].toString()) ??
                  DateTime.now();
          return bDate.compareTo(aDate);
        });

        return Column(
          children: completedDocs.map((data) {
            return _appointmentCard(
              formatDateTime(data['appointmentdate']),
              data['queuenum']?.toString() ?? "-",
            );
          }).toList(),
        );
      },
    );
  }

  Widget _appointmentCard(String date, String queueNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.purple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "View",
                        style: GoogleFonts.poppins(
                            color: Colors.purple, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Edit",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  "Queue",
                  style:
                      GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                ),
                Text(
                  queueNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
