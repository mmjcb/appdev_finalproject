import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_queues.dart';
import 'admin_archives.dart';

typedef QueueCardTapCallback = void Function({
  required String userId,
  required String appointmentNum,
  required String purpose,
  required int queueNum,
  required Timestamp appointmentDate,
});

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String? selectedAppointmentNum;
  String? selectedPurpose;
  int? selectedQueueNum;
  Timestamp? selectedAppointmentDate;
  String? selectedUserId;

  static const Color gradientStart = Color.fromARGB(162, 234, 189, 230);
  static const Color gradientEnd = Color(0xFFD69ADE);
  static const Color purpleDark = Color(0xFF4B367C);
  static const Color purpleMid = Color(0xFF7C58D3);
  static const Color purpleLight = Color(0xFFCBBAE0);

  String activePage = "Home";
  Timer? autoArchiveTimer;

  @override
  void initState() {
    super.initState();
    // Run automatic archive on startup
    _autoArchivePastAppointments();
    // Periodic auto-archive every 5 minutes
    autoArchiveTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _autoArchivePastAppointments();
    });
  }

  @override
  void dispose() {
    autoArchiveTimer?.cancel();
    super.dispose();
  }

  /// Automatically archive past appointments
  Future<void> _autoArchivePastAppointments() async {
    try {
      final now = DateTime.now();
      final appointmentsRef =
          FirebaseFirestore.instance.collection('appointments');
      final archivesRef = FirebaseFirestore.instance.collection('archives');
      final tellerRef =
          FirebaseFirestore.instance.collection('tellers').doc('teller3');

      final snapshot = await appointmentsRef.get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final appointmentDate = (data['appointmentdate'] as Timestamp).toDate();

        if (appointmentDate.isBefore(now)) {
          // Archive the appointment
          await archivesRef.doc(doc.id).set({
            ...data,
            'status': 'missed',
            'archivedAt': Timestamp.now(),
          });

          await appointmentsRef.doc(doc.id).delete();
        }
      }

      // Recalculate queue numbers
      final remainingAppointments =
          await appointmentsRef.orderBy('appointmentdate').get();
      for (int i = 0; i < remainingAppointments.docs.length; i++) {
        await appointmentsRef
            .doc(remainingAppointments.docs[i].id)
            .update({'queuenum': i + 1});
      }

      // Check if current serving appointment has expired
      final tellerSnap = await tellerRef.get();
      if (tellerSnap.exists) {
        final currentData = tellerSnap.data() as Map<String, dynamic>? ?? {};
        final currentAppointmentDate = currentData['appointmentDate'] != null
            ? (currentData['appointmentDate'] as Timestamp).toDate()
            : null;

        if (currentAppointmentDate != null &&
            currentAppointmentDate.isBefore(now)) {
          await tellerRef.set({
            'currentUserId': "",
            'currentAppointment': "-",
            'purpose': "-",
            'currentQueue': "-",
            'appointmentDate': null,
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      print("Error in auto-archiving: $e");
    }
  }

  void _handleQueueCardTap({
    required String userId,
    required String appointmentNum,
    required String purpose,
    required int queueNum,
    required Timestamp appointmentDate,
  }) async {
    setState(() {
      selectedUserId = userId;
      selectedAppointmentNum = appointmentNum;
      selectedPurpose = purpose;
      selectedQueueNum = queueNum;
      selectedAppointmentDate = appointmentDate;
    });

    try {
      await FirebaseFirestore.instance
          .collection('tellers')
          .doc('teller3')
          .set({
        'currentUserId': userId,
        'currentAppointment': appointmentNum,
        'purpose': purpose,
        'currentQueue': queueNum,
        'appointmentDate': appointmentDate,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving teller status: $e');
    }
  }

  Future<void> _archiveCurrentQueue({
    required String currentUserId,
    required dynamic currentAppointment,
    required dynamic currentQueue,
    required String purpose,
    required String status,
  }) async {
    try {
      final appointmentsRef =
          FirebaseFirestore.instance.collection('appointments');
      final archivesRef = FirebaseFirestore.instance.collection('archives');
      final tellerRef =
          FirebaseFirestore.instance.collection('tellers').doc('teller3');

      final query = await appointmentsRef
          .where('appointmentnum', isEqualTo: currentAppointment)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return;

      final doc = query.docs.first;
      final data = doc.data();
      final appointmentDate = (data['appointmentdate'] as Timestamp).toDate();

      // Disable "Next" if appointment is not today
      final today = DateTime.now();
      final isToday = appointmentDate.year == today.year &&
          appointmentDate.month == today.month &&
          appointmentDate.day == today.day;

      if (!isToday && status == "completed") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Cannot mark as completed. Appointment is not today."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Archive the appointment
      await archivesRef.doc(doc.id).set({
        ...data,
        'status': status,
        'archivedAt': Timestamp.now(),
      });

      await appointmentsRef.doc(doc.id).delete();

      // Recalculate queue numbers
      final remainingAppointments =
          await appointmentsRef.orderBy('appointmentdate').get();
      for (int i = 0; i < remainingAppointments.docs.length; i++) {
        await appointmentsRef
            .doc(remainingAppointments.docs[i].id)
            .update({'queuenum': i + 1});
      }

      // Load next in queue
      final nextQuery =
          await appointmentsRef.orderBy('appointmentdate').limit(1).get();
      if (nextQuery.docs.isNotEmpty) {
        final nextData = nextQuery.docs.first.data();
        await tellerRef.set({
          'currentUserId': nextData['userId'],
          'currentAppointment': nextData['appointmentnum'],
          'purpose': nextData['purpose'],
          'currentQueue': 1,
          'appointmentDate': nextData['appointmentdate'],
        }, SetOptions(merge: true));
      } else {
        await tellerRef.set({
          'currentUserId': "",
          'currentAppointment': "-",
          'purpose': "-",
          'currentQueue': "-",
          'appointmentDate': null,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("Error archiving queue: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return _buildMobileLayout(context);
        }
        return _buildDesktopLayout(context);
      },
    );
  }

  // ---------------- MOBILE LAYOUT ----------------
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: purpleDark,
        elevation: 0,
        title: Text(
          "SkipQ",
          style: GoogleFonts.poppins(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: purpleMid,
              radius: 18,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      drawer: _buildMobileDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTellerInfoCard(),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: IntrinsicHeight(child: _buildQueueList(isDesktop: false)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "SkipQ",
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: purpleDark),
                ),
              ),
            ),
            const SizedBox(height: 50),
            SidebarItem(
              icon: Icons.home,
              label: "Home",
              isActive: activePage == "Home",
              activeColor: purpleDark,
              onTap: () {
                setState(() => activePage = "Home");
                Navigator.pop(context);
              },
            ),
            SidebarItem(
              icon: Icons.list_alt,
              label: "Queues",
              isActive: activePage == "Queues",
              activeColor: purpleDark,
              onTap: () {
                setState(() => activePage = "Queues");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QueuesPage()),
                );
              },
            ),
            SidebarItem(
              icon: Icons.archive,
              label: "Archives",
              isActive: activePage == "Archives",
              activeColor: purpleDark,
              onTap: () {
                setState(() => activePage = "Archives");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ArchivesPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTellerInfoCard({bool isDesktop = false}) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tellers')
          .doc('teller3')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
              height: isDesktop ? null : 200,
              child: const Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final currentQueue = data['currentQueue'] ?? "-";
        final currentAppointment = data['currentAppointment'] ?? "-";
        final purpose = data['purpose'] ?? "-";
        final userId = data['currentUserId'] ?? "";
        final appointmentDate = data['appointmentDate'] != null
            ? (data['appointmentDate'] as Timestamp).toDate()
            : null;

        bool isToday = false;
        if (appointmentDate != null) {
          final today = DateTime.now();
          isToday = appointmentDate.year == today.year &&
              appointmentDate.month == today.month &&
              appointmentDate.day == today.day;
        }

        if (userId.isEmpty || currentAppointment == "-") {
          return _buildServingCardContent(
            context,
            currentQueue: "-",
            currentAppointment: "-",
            purpose: "No one currently serving",
            customerName: "---",
            userId: "",
            isDesktop: isDesktop,
            canNext: false,
          );
        }

        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, userSnapshot) {
            String customerName = "Loading...";
            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
              final fname = userData['firstName'] ?? "";
              final mid = userData['middleInitial'] ?? "";
              final lname = userData['lastName'] ?? "";
              final ext = userData['ext'] ?? "";

              customerName =
                  "$fname${mid.isNotEmpty ? ' $mid' : ''} $lname${ext.isNotEmpty ? ', $ext' : ''}"
                      .trim();
            } else if (userSnapshot.hasError) {
              customerName = "Error loading name";
            }

            return _buildServingCardContent(
              context,
              currentQueue: currentQueue,
              currentAppointment: currentAppointment,
              purpose: purpose,
              customerName: customerName,
              userId: userId,
              isDesktop: isDesktop,
              canNext: isToday,
            );
          },
        );
      },
    );
  }

  Widget _buildServingCardContent(
    BuildContext context, {
    required dynamic currentQueue,
    required dynamic currentAppointment,
    required dynamic purpose,
    required String customerName,
    String? userId,
    bool isDesktop = false,
    required bool canNext,
    Color? cardColor,
  }) {
    return Card(
      color: cardColor ?? purpleDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "NOW SERVING",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: purpleLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            Text(
              customerName.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 32),
            ),
            const SizedBox(height: 16),
            DetailRow(
                label: "Appointment ID",
                value: currentAppointment.toString(),
                labelColor: purpleLight,
                valueColor: Colors.white),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Purpose of Appointment",
                style: GoogleFonts.poppins(
                    color: purpleLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                purpose,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
            ),
            const Spacer(),
            if (userId != null && userId.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _archiveCurrentQueue(
                              currentUserId: userId,
                              currentAppointment: currentAppointment,
                              currentQueue: currentQueue,
                              purpose: purpose,
                              status: "cancelled"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: Text('Cancel',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: canNext
                              ? () => _archiveCurrentQueue(
                                    currentUserId: userId,
                                    currentAppointment: currentAppointment,
                                    currentQueue: currentQueue,
                                    purpose: purpose,
                                    status: "completed",
                                  )
                              : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  canNext ? purpleMid : Colors.grey[400],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: Text('Next',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- QUEUE LIST ----------------
  Widget _buildQueueList({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "In Line",
              style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 24 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            FilterDropdown(purpleMid: purpleMid),
          ],
        ),
        SizedBox(height: isDesktop ? 20 : 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .orderBy('appointmentdate')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Center(
                    child: Text("No appointments in the queue.",
                        style: GoogleFonts.poppins(color: Colors.grey)));
              }
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final queueNumber = index + 1;
                  if (doc['queuenum'] != queueNumber) {
                    Future.microtask(() {
                      FirebaseFirestore.instance
                          .collection('appointments')
                          .doc(doc.id)
                          .update({'queuenum': queueNumber});
                    });
                  }
                  return QueueCard(
                    queuenum: queueNumber,
                    appointmentnum: doc['appointmentnum'],
                    appointmentdate: doc['appointmentdate'],
                    purpose: doc['purpose'],
                    purpleMid: purpleMid,
                    userId: doc['userId'],
                    onTap: _handleQueueCardTap,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------- DESKTOP LAYOUT ----------------
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          Container(
            width: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "SkipQ",
                      style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: purpleDark),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                SidebarItem(
                    icon: Icons.home,
                    label: "Home",
                    isActive: activePage == "Home",
                    activeColor: purpleDark,
                    onTap: () => setState(() => activePage = "Home")),
                SidebarItem(
                  icon: Icons.list_alt,
                  label: "Queues",
                  isActive: activePage == "Queues",
                  activeColor: purpleDark,
                  onTap: () {
                    setState(() => activePage = "Queues");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const QueuesPage()));
                  },
                ),
                SidebarItem(
                  icon: Icons.archive,
                  label: "Archives",
                  isActive: activePage == "Archives",
                  activeColor: purpleDark,
                  onTap: () {
                    setState(() => activePage = "Archives");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ArchivesPage()));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Dashboard",
                          style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      CircleAvatar(
                        backgroundColor: purpleMid,
                        radius: 22,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16)),
                            child: _buildQueueList(isDesktop: true),
                          ),
                        ),
                        const SizedBox(width: 24),
                        SizedBox(
                            width: 400,
                            child: _buildTellerInfoCard(isDesktop: true)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- WIDGETS ----------------
class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback? onTap;

  const SidebarItem(
      {super.key,
      required this.icon,
      required this.label,
      this.isActive = false,
      required this.activeColor,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final textColor = isActive ? activeColor : activeColor.withOpacity(0.7);
    return ListTile(
      dense: true,
      leading: Icon(icon, color: textColor),
      title: Text(label,
          style: GoogleFonts.poppins(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
              color: textColor)),
      onTap: onTap,
    );
  }
}

class FilterDropdown extends StatefulWidget {
  final Color purpleMid;
  const FilterDropdown({super.key, required this.purpleMid});

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  String dropdownValue = 'Regular';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          border: Border.all(color: widget.purpleMid),
          borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownValue,
          icon: Container(
            decoration: BoxDecoration(
                color: widget.purpleMid,
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              "Filter",
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          onChanged: (String? newValue) {
            if (newValue != null) setState(() => dropdownValue = newValue);
          },
          items: ['Regular', 'Priority']
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 12)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class QueueCard extends StatelessWidget {
  final int? queuenum;
  final String appointmentnum;
  final Timestamp appointmentdate;
  final String purpose;
  final Color purpleMid;
  final String userId;
  final QueueCardTapCallback? onTap;

  const QueueCard(
      {super.key,
      required this.queuenum,
      required this.appointmentnum,
      required this.appointmentdate,
      required this.purpose,
      required this.purpleMid,
      required this.userId,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = appointmentdate.toDate();
    final formattedDate = "${date.month}/${date.day}/${date.year}";
    final formattedTime =
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        String customerName = "Loading...";
        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final fname = userData['firstName'] ?? "";
          final mid = userData['middleInitial'] ?? "";
          final lname = userData['lastName'] ?? "";
          final ext = userData['ext'] ?? "";
          customerName =
              "$fname${mid.isNotEmpty ? ' $mid' : ''} $lname${ext.isNotEmpty ? ', $ext' : ''}"
                  .trim();
        } else if (snapshot.hasError) {
          customerName = "Error loading name";
        }

        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: EdgeInsets.zero,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              if (onTap != null) {
                onTap!(
                    userId: userId,
                    appointmentNum: appointmentnum,
                    purpose: purpose,
                    queueNum: queuenum ?? 0,
                    appointmentDate: appointmentdate);
              }
            },
            leading: CircleAvatar(
              backgroundColor: purpleMid,
              child: Text(
                queuenum.toString(),
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(customerName,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 16)),
            subtitle: Text("$formattedDate | $formattedTime | $purpose",
                style:
                    GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        );
      },
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  const DetailRow(
      {super.key,
      required this.label,
      required this.value,
      required this.labelColor,
      required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                color: labelColor, fontWeight: FontWeight.w700, fontSize: 14)),
        Text(value,
            style: GoogleFonts.poppins(
                color: valueColor, fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }
}
