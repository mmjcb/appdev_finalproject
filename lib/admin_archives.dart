import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArchivesPage extends StatelessWidget {
  const ArchivesPage({super.key});

  static const Color purpleDark = Color(0xFF4B367C);
  static const Color purpleMid = Color(0xFF7C58D3);
  static const Color gradientStart = Color.fromARGB(162, 234, 189, 230);
  static const Color gradientEnd = Color(0xFFD69ADE);

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

  // ---------------- DESKTOP LAYOUT ----------------

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          _buildSidebar(context),
          _buildMainTableSection(),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
            activeColor: purpleDark,
            onTapAction: () => Navigator.pop(context),
          ),
          SidebarItem(
            icon: Icons.list_alt,
            label: "Queues",
            activeColor: purpleDark,
          ),
          SidebarItem(
            icon: Icons.archive,
            label: "Archives",
            isActive: true,
            activeColor: purpleDark,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: purpleDark,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTableSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(40),
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Archived Appointments",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: purpleDark,
              ),
            ),
            const SizedBox(height: 25),
            _tableView(),
          ],
        ),
      ),
    );
  }

  Widget _tableView() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: purpleDark),
        ),
        child: Column(
          children: [
            _tableHeader(),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('archives')
                    .orderBy('archivedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No archived appointments",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 20, endIndent: 20),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return _archiveRow(data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: const [
          _HeaderCell("Queue ID", flex: 2),
          _HeaderCell("Appointment ID", flex: 2),
          _HeaderCell("Name", flex: 3),
          _HeaderCell("Date", flex: 2),
          _HeaderCell("Status", flex: 2),
        ],
      ),
    );
  }

  Widget _archiveRow(Map<String, dynamic> data) {
    final Timestamp ts = data['appointmentdate'];
    final date = ts.toDate();
    final formattedDate = "${date.month}/${date.day}/${date.year}";

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(data['userId'])
          .get(),
      builder: (context, snapshot) {
        String name = "Loading...";
        if (snapshot.hasData && snapshot.data!.exists) {
          final u = snapshot.data!.data() as Map<String, dynamic>;
          name = "${u['firstName']} ${u['lastName']}".trim();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              _RowCell(data['queuenum'].toString(), flex: 2),
              _RowCell(data['appointmentnum'], flex: 2),
              _RowCell(name, flex: 3),
              _RowCell(formattedDate, flex: 2),
              Expanded(
                flex: 2,
                child: StatusChip(status: data['status']),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- MOBILE ----------------

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Archives"),
        backgroundColor: purpleMid,
      ),
      body: const Center(child: Text("Mobile view")),
    );
  }
}

// ---------------- SUPPORTING WIDGETS ----------------

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'completed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCompleted ? 'Completed' : 'Cancelled',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback? onTapAction;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.activeColor,
    this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : activeColor.withOpacity(0.7);

    return ListTile(
      dense: true,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          fontSize: 14,
          color: color,
        ),
      ),
      onTap: onTapAction,
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;

  const _HeaderCell(this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: ArchivesPage.purpleDark,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _RowCell extends StatelessWidget {
  final String text;
  final int flex;

  const _RowCell(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 13),
      ),
    );
  }
}
