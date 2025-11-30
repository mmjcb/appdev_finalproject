import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            _headerControls(),
            const SizedBox(height: 25),
            _tableView(),
          ],
        ),
      ),
    );
  }

  Widget _headerControls() {
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
              color: Color.fromARGB(255, 76, 1, 78),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.search,
                  size: 20, color: Color.fromARGB(255, 76, 1, 78)),
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: GoogleFonts.poppins(fontSize: 13),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
            child: DropdownButton(
              value: "Name (A-Z)",
              items: ["Name (A-Z)", "Name (Z-A)"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableView() {
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

            // Sample Row
            _tableRow(
              queueID: "SQ092",
              appointmentID: "APT122",
              name: "Den Karryl Subosa",
              date: "09 - 23 - 25",
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
        ),
      ),
    );
  }

  Widget _tableRow({
    required String queueID,
    required String appointmentID,
    required String name,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _rowCell(queueID, flex: 2),
          _rowCell(appointmentID, flex: 2),
          _rowCell(name, flex: 3),
          _rowCell(date, flex: 2),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              children: const [
                Icon(Icons.visibility, size: 20),
                SizedBox(width: 12),
                Icon(Icons.delete, size: 20),
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
        style: GoogleFonts.poppins(fontSize: 13),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Mobile layout simplified for demo",
          style: GoogleFonts.poppins(fontSize: 18),
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
