import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_queues.dart';
import 'admin_archives.dart';

// Define a type for the QueueCard's callback function
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
  // --- Style Constants ---
  static const Color gradientStart = Color.fromARGB(162, 234, 189, 230);
  static const Color gradientEnd = Color(0xFFD69ADE);
  static const Color purpleDark = Color(0xFF4B367C);
  static const Color purpleMid = Color(0xFF7C58D3);
  static const Color purpleLight = Color(0xFFCBBAE0);

  String activePage = "Home";

  void _handleQueueCardTap({
    required String userId,
    required String appointmentNum,
    required String purpose,
    required int queueNum,
    required Timestamp appointmentDate,
  }) async {
    // 1. Log the selection (optional, for debugging)
    print('Queue Card Tapped: Appointment $appointmentNum, Queue $queueNum');

    // 2. Update the 'teller3' document in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('tellers')
          .doc('teller3')
          .update({
        'currentUserId': userId,
        'currentAppointment': appointmentNum,
        'purpose': purpose,
        'currentQueue': queueNum,
        'appointmentDate':
            appointmentDate, // Storing the Timestamp for the right panel
      });
      // The _buildTellerInfoPanelDesktop StreamBuilder will automatically update the UI
    } catch (e) {
      print('Error updating teller status: $e');
      // Optionally show a snackbar error to the user
    }
  }

  // ------------------------------------
  // --- FIXED: REQUIRED BUILD METHOD ---
  // ------------------------------------

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

  // ------------------------------------
  // --- MOBILE LAYOUT BUILDERS (omitted for brevity, assume they are correct) ---
  // ------------------------------------

  // NOTE: The rest of _buildMobileLayout, _buildMobileDrawer,
  // _buildServingCardContent, and _buildTellerInfoCard remain the same
  // as the previous corrected version.

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: purpleDark,
        elevation: 0,
        title: Text(
          "SkipQ",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "In Line",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      FilterDropdown(purpleMid: purpleMid),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Mobile Queue List Fetcher
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .orderBy('createdAt')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs;

                      return Column(
                        children: docs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final doc = entry.value;

                          final queueNumber = index + 1;

                          // Update 'queuenum' based on current index
                          if (doc['queuenum'] != queueNumber) {
                            FirebaseFirestore.instance
                                .collection('appointments')
                                .doc(doc.id)
                                .update({'queuenum': queueNumber});
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: QueueCard(
                              queuenum: queueNumber,
                              appointmentnum: doc['appointmentnum'],
                              appointmentdate: doc['appointmentdate'],
                              purpose: doc['purpose'],
                              purpleMid: purpleMid,
                              userId: doc['userId'],
                              onTap: _handleQueueCardTap,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
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
                    color: purpleDark,
                  ),
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

  Widget _buildServingCardContent(
    BuildContext context, {
    required dynamic currentQueue,
    required dynamic currentAppointment,
    required dynamic purpose,
    required String customerName,
  }) {
    // Mobile card layout
    return Container(
      width: double.infinity,
      color: purpleDark,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            "NOW SERVING",
            style: GoogleFonts.poppins(
              color: purpleLight,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currentQueue.toString(),
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),
          DetailRow(
              label: "Customer Name",
              value: customerName,
              labelColor: purpleLight,
              valueColor: Colors.white),
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
                fontSize: 14,
              ),
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
        ],
      ),
    );
  }

  Widget _buildTellerInfoCard() {
    // Mobile Teller Info Fetcher
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tellers')
          .doc('teller3')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final currentQueue = data['currentQueue'] ?? "-";
        final currentAppointment = data['currentAppointment'] ?? "-";
        final purpose = data['purpose'] ?? "-";
        final userId = data['currentUserId'] ?? "";

        if (userId.isEmpty) {
          return _buildServingCardContent(
            context,
            currentQueue: currentQueue,
            currentAppointment: currentAppointment,
            purpose: purpose,
            customerName: "-",
          );
        }

        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, userSnapshot) {
            String customerName = "-";
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
            }

            return _buildServingCardContent(
              context,
              currentQueue: currentQueue,
              currentAppointment: currentAppointment,
              purpose: purpose,
              customerName: customerName,
            );
          },
        );
      },
    );
  }

  // ------------------------------------
  // --- DESKTOP LAYOUT BUILDERS ---
  // ------------------------------------

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            Container(
              width: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      "SkipQ",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: purpleDark,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QueuesPage()),
                        );
                      }),
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
                              builder: (_) => const ArchivesPage()),
                        );
                      }),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircleAvatar(
                      backgroundColor: purpleDark,
                      radius: 20,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // Middle panel (Queue List)
            Expanded(
              flex: 3,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Admin",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        FilterDropdown(purpleMid: purpleMid),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "In Line",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      // Desktop Queue List Fetcher
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('appointments')
                            .orderBy('createdAt')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final docs = snapshot.data!.docs;

                          return ListView(
                            padding: EdgeInsets.zero,
                            children: docs.asMap().entries.map((entry) {
                              final index = entry.key;
                              final doc = entry.value;

                              final queueNumber = index + 1;
                              if (doc['queuenum'] != queueNumber) {
                                FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc(doc.id)
                                    .update({'queuenum': queueNumber});
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: QueueCard(
                                  queuenum: queueNumber,
                                  appointmentnum: doc['appointmentnum'],
                                  appointmentdate: doc['appointmentdate'],
                                  purpose: doc['purpose'],
                                  purpleMid: purpleMid,
                                  userId: doc['userId'],
                                  // Pass the handler for click functionality
                                  onTap: _handleQueueCardTap,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right panel (Now Serving)
            Expanded(flex: 2, child: _buildTellerInfoPanelDesktop()),
          ],
        ),
      ),
    );
  }

  // --- DESKTOP NOW SERVING PANEL CONTENT (REDESIGNED) ---
  Widget _buildServingPanelContentDesktop(
    BuildContext context, {
    required dynamic currentQueue,
    required dynamic currentAppointment,
    required dynamic purpose,
    required String customerName,
    required dynamic rawAppointmentDate,
  }) {
    String formattedDate = '-';
    String formattedTime = '-';

    if (rawAppointmentDate is Timestamp) {
      final date = rawAppointmentDate.toDate();
      formattedDate =
          "${date.day}/${date.month}/${date.year}"; // Format: DD/MM/YYYY
      formattedTime =
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}";
    }

    // Check if a customer is actually being served
    final isServing = customerName != "-";

    return Container(
      decoration: BoxDecoration(
        color: purpleDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // NOW SERVING Header
          const SizedBox(height: 12),
          Text(
            "NOW SERVING!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: purpleLight,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 48),

          // Customer Name (DEN SUBOSA)
          Text(
            customerName,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 4),

          // Appointment ID (SQ0021)
          Text(
            currentAppointment.toString(),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 40),

          // Details Section (Purpose, Date, Time)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Purpose
                    Text(
                      purpose.toString(),
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                    Text(
                      "Purpose",
                      style: GoogleFonts.poppins(
                          color: purpleLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                    const SizedBox(height: 20),

                    // Date
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                    Text(
                      "Date",
                      style: GoogleFonts.poppins(
                          color: purpleLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                    const SizedBox(height: 20),

                    // Time
                    Text(
                      formattedTime,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                    Text(
                      "Time",
                      style: GoogleFonts.poppins(
                          color: purpleLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Queue Number Badge (9)
              Expanded(
                flex: 1,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: purpleLight,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentQueue.toString(),
                        style: GoogleFonts.poppins(
                          color: purpleDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 60,
                          height: 1, // Minimize vertical space
                        ),
                      ),
                      Text(
                        "Queue Number",
                        style: GoogleFonts.poppins(
                          color: purpleDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          height: 1, // Minimize vertical space
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Action Buttons (Only show if a customer is being served)
          if (isServing)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Cancel Button
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement cancel logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                // Next Button
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement 'Next' serving logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purpleMid,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
    );
  }

  // Desktop Teller Info Fetcher
  Widget _buildTellerInfoPanelDesktop() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tellers')
          .doc('teller3')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final currentQueue = data['currentQueue'] ?? "-";
        final currentAppointment = data['currentAppointment'] ?? "-";
        final purpose = data['purpose'] ?? "-";
        final userId = data['currentUserId'] ?? "";
        final appointmentDate = data['appointmentDate'] ?? null;

        if (userId.isEmpty) {
          // Default state when no one is being served
          return _buildServingPanelContentDesktop(
            context,
            currentQueue: currentQueue,
            currentAppointment: currentAppointment,
            purpose: purpose,
            customerName: "-",
            rawAppointmentDate: appointmentDate,
          );
        }

        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, userSnapshot) {
            String customerName = "-";
            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
              final firstName = userData['firstName'] ?? "";
              final middleInitial = userData['middleInitial'] ?? "";
              final lastName = userData['lastName'] ?? "";
              final ext = userData['ext'] ?? "";

              customerName =
                  "$firstName${middleInitial.isNotEmpty ? ' $middleInitial' : ''} $lastName${ext.isNotEmpty ? ', $ext' : ''}"
                      .trim();
            }

            return _buildServingPanelContentDesktop(
              context,
              currentQueue: currentQueue,
              currentAppointment: currentAppointment,
              purpose: purpose,
              customerName: customerName,
              rawAppointmentDate: appointmentDate,
            );
          },
        );
      },
    );
  }
}

// ------------------------------------
// --- REUSABLE WIDGETS (remain the same) ---
// ------------------------------------

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback? onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.activeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isActive ? activeColor : activeColor.withOpacity(0.7);
    return ListTile(
      dense: true,
      leading: Icon(icon, color: textColor),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          fontSize: 14,
          color: textColor,
        ),
      ),
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
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdownValue,
          icon: Container(
            decoration: BoxDecoration(
              color: widget.purpleMid,
              borderRadius: BorderRadius.circular(12),
            ),
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

  const QueueCard({
    super.key,
    required this.queuenum,
    required this.appointmentnum,
    required this.appointmentdate,
    required this.purpose,
    required this.purpleMid,
    required this.userId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = appointmentdate.toDate();
    final formattedDate = "${date.month}/${date.day}/${date.year}";
    final formattedTime =
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    return FutureBuilder<DocumentSnapshot>(
      // Fetches customer name using userId
      future: userId.isNotEmpty
          ? FirebaseFirestore.instance.collection('users').doc(userId).get()
          : Future.value(null),
      builder: (context, snapshot) {
        String customerName = "-";
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final fname = data['firstName'] ?? "";
          final mid = data['middleInitial'] ?? "";
          final lname = data['lastName'] ?? "";
          customerName = "$fname${mid.isNotEmpty ? ' $mid' : ''} $lname".trim();
        }

        return InkWell(
          onTap: () {
            if (onTap != null && queuenum != null) {
              onTap!(
                userId: userId,
                appointmentNum: appointmentnum,
                purpose: purpose,
                queueNum: queuenum!,
                appointmentDate: appointmentdate,
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: purpleMid.withOpacity(0.15),
              border: Border.all(color: purpleMid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(
                    label: "Queue Number:", value: queuenum?.toString() ?? "-"),
                InfoRow(label: "Customer Name:", value: customerName),
                InfoRow(label: "Appointment ID:", value: appointmentnum),
                InfoRow(label: "Date:", value: formattedDate),
                InfoRow(label: "Time:", value: formattedTime),
                InfoRow(label: "Purpose:", value: purpose),
              ],
            ),
          ),
        );
      },
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
          children: [
            TextSpan(
                text: label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: " $value"),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: labelColor, fontSize: 14)),
        Text(value,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: valueColor, fontSize: 14)),
      ],
    );
  }
}
