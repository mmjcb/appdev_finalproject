import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- MOCK DATA STRUCTURE ---

enum AppointmentStatus { complete, cancelled }

class Appointment {
  final String queueID;
  final String appointmentID;
  final String name;
  final String date;
  final AppointmentStatus status;

  Appointment({
    required this.queueID,
    required this.appointmentID,
    required this.name,
    required this.date,
    required this.status,
  });
}

// --- MOCK DATA ---
final List<Appointment> mockArchives = [
  Appointment(
    queueID: "SQ092",
    appointmentID: "APT122",
    name: "Den Karryl Subosa",
    date: "09 - 23 - 25",
    status: AppointmentStatus.complete,
  ),
  Appointment(
    queueID: "SQ088",
    appointmentID: "APT118",
    name: "Jane Doe",
    date: "09 - 22 - 25",
    status: AppointmentStatus.cancelled,
  ),
  Appointment(
    queueID: "SQ095",
    appointmentID: "APT125",
    name: "Alice Johnson",
    date: "09 - 24 - 25",
    status: AppointmentStatus.complete,
  ),
  Appointment(
    queueID: "SQ081",
    appointmentID: "APT111",
    name: "Bob Smith",
    date: "09 - 20 - 25",
    status: AppointmentStatus.cancelled,
  ),
];

// --- ARCHIVES PAGE WIDGET ---

class ArchivesPage extends StatelessWidget {
  const ArchivesPage({super.key});

  static const Color purpleDark = Color(0xFF4B367C);
  static const Color purpleMid = Color(0xFF7C58D3);
  static const Color purpleLight = Color(0xFFC3B4E2);
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
    // ... (Sidebar content is unchanged)
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

          // Logo / Title
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

          // Sidebar Items
          SidebarItem(
            icon: Icons.home,
            label: "Home",
            isActive: false,
            activeColor: purpleDark,
            onTapAction: () {
              Navigator.pop(context);
            },
          ),

          SidebarItem(
            icon: Icons.list_alt,
            label: "Queues",
            isActive: false,
            activeColor: purpleDark,
          ),

          SidebarItem(
            icon: Icons.archive,
            label: "Archives",
            isActive: true,
            activeColor: purpleDark,
          ),

          const Spacer(),

          // Profile Icon
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
            _headerControls(),
            const SizedBox(height: 25),
            _tableView(),
          ],
        ),
      ),
    );
  }

  Widget _headerControls() {
    // ... (Header controls are unchanged)
    return Row(
      children: [
        // Search Bar
        Container(
          width: 260,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color.fromARGB(255, 76, 1, 78),
              width: 1,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.search,
                  size: 20, color: Color.fromARGB(255, 76, 1, 78)),
              SizedBox(width: 15),
              Expanded(
                child: TextField(
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(fontSize: 13),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        // Sort Dropdown
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color.fromARGB(255, 76, 1, 78),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: "Date (Newest)",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
              items: [
                "Date (Newest)",
                "Date (Oldest)",
                "Name (A-Z)",
                "Name (Z-A)"
              ]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (_) {
                // Sorting logic goes here
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableView() {
    // ... (Table view structure is unchanged)
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 76, 1, 78),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _tableHeader(),
            const Divider(height: 1),

            // Use a ListView.builder for potentially large lists
            Expanded(
              child: ListView.builder(
                itemCount: mockArchives.length,
                itemBuilder: (context, index) {
                  final appointment = mockArchives[index];
                  return Column(
                    children: [
                      _tableRow(
                        queueID: appointment.queueID,
                        appointmentID: appointment.appointmentID,
                        name: appointment.name,
                        date: appointment.date,
                        status: appointment.status,
                      ),
                      if (index < mockArchives.length - 1)
                        const Divider(height: 1, indent: 20, endIndent: 20),
                    ],
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
        children: [
          _headerCell("Queue ID", flex: 2),
          _headerCell("Appointment ID", flex: 2),
          _headerCell("Name", flex: 3),
          _headerCell("Date", flex: 2),
          _headerCell("Status", flex: 2),
          _headerCell("Actions", flex: 2),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: purpleDark,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _tableRow({
    required String queueID,
    required String appointmentID,
    required String name,
    required String date,
    required AppointmentStatus status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _rowCell(queueID, flex: 2),
          _rowCell(appointmentID, flex: 2),
          _rowCell(name, flex: 3),
          _rowCell(date, flex: 2),

          // Status Cell
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(status: status),
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Tooltip(
                  message: "View Details",
                  child: Icon(Icons.visibility, size: 20, color: purpleMid),
                ),
                const SizedBox(width: 12),
                Tooltip(
                  message: "Delete Record",
                  child: Icon(Icons.delete, size: 20, color: Colors.red[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Archives", style: GoogleFonts.poppins()),
        backgroundColor: purpleMid,
      ),
      body: Center(
        child: Text(
          "Mobile layout simplified for demo",
          style: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
    );
  }
}

// --- REVISED STATUS CHIP WIDGET FOR VISUAL CONSISTENCY ---

class StatusChip extends StatelessWidget {
  final AppointmentStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    Color textColor;
    String text;

    // Define consistent colors for the status chips
    const Color completeColor = Color(0xFF00C853); // A vibrant Green
    const Color cancelledColor = Color(0xFFD50000); // A vibrant Red

    switch (status) {
      case AppointmentStatus.complete:
        chipColor = completeColor;
        textColor = Colors.white;
        text = "Complete";
        break;
      case AppointmentStatus.cancelled:
        chipColor = cancelledColor;
        textColor = Colors.white;
        text = "Canceled";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      constraints: const BoxConstraints(minWidth: 80),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: chipColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// --- SIDEBAR ITEM (Unchanged, but included for completeness) ---

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
    final textColor = isActive ? activeColor : activeColor.withOpacity(0.7);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: textColor),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          fontSize: 14,
          color: textColor,
        ),
      ),
      onTap: onTapAction,
    );
  }
}