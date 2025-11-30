import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_archives.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  static const Color gradientStart = Color.fromARGB(162, 234, 189, 230);
  static const Color gradientEnd = Color(0xFFD69ADE);
  static const Color purpleDark = Color(0xFF4B367C);
  static const Color purpleMid = Color(0xFF7C58D3);
  static const Color purpleLight = Color(0xFFCBBAE0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile layout for screens narrower than 800px
        if (constraints.maxWidth < 800) {
          return _buildMobileLayout(context);
        }
        // Desktop layout for wider screens
        return _buildDesktopLayout(context);
      },
    );
  }

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
            // Teller Info Section (at top on mobile)
            _buildTellerInfoCard(context),

            // Queue List Section
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
                  QueueCard(
                    name: "Jelliane Abono",
                    queueID: "SQ093",
                    appointmentID: "APT123",
                    serviceNeeded: "Open New Account",
                    purpleMid: purpleMid,
                  ),
                  const SizedBox(height: 12),
                  QueueCard(
                    name: "Ace Vincent",
                    queueID: "SQ094",
                    appointmentID: "APT124",
                    serviceNeeded: "Foreign Exchange Request",
                    purpleMid: purpleMid,
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
        decoration: BoxDecoration(
          gradient: const LinearGradient(
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
            const SizedBox(height: 40),
            SidebarItem(
                icon: Icons.home,
                label: "Home",
                isActive: true,
                activeColor: purpleDark),
            SidebarItem(
                icon: Icons.list_alt, label: "Queues", activeColor: purpleDark),
            SidebarItem(
                icon: Icons.archive,
                label: "Archives",
                activeColor: purpleDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTellerInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: purpleDark,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            "TELLER 3",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "NOW SERVING",
            style: GoogleFonts.poppins(
              color: purpleLight,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Den Karryl",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "SQ092",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          DetailRow(
            label: "Appointment ID",
            value: "APT122",
            labelColor: purpleLight,
            valueColor: Colors.white,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Service Needed",
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
              "Report Lost/Stolen Card",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PurpleButton(
                  label: "View",
                  purpleMid: purpleMid,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PurpleButton(
                  label: "Next",
                  purpleMid: purpleMid,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Row(
          children: [
            // Left Sidebar
            Container(
              width: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [gradientStart, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
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
                      isActive: true,
                      activeColor: purpleDark),
                  SidebarItem(
                      icon: Icons.list_alt,
                      label: "Queues",
                      activeColor: purpleDark),
                  SidebarItem(
                      icon: Icons.archive,
                      label: "Archives",
                      activeColor: purpleDark),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircleAvatar(
                      backgroundColor: purpleDark,
                      radius: 20,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Middle section: Filter + In Line list
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          QueueCard(
                            name: "Jelliane Abono",
                            queueID: "SQ093",
                            appointmentID: "APT123",
                            serviceNeeded: "Open New Account",
                            purpleMid: purpleMid,
                          ),
                          const SizedBox(height: 12),
                          QueueCard(
                            name: "Ace Vincent",
                            queueID: "SQ094",
                            appointmentID: "APT124",
                            serviceNeeded: "Foreign Exchange Request",
                            purpleMid: purpleMid,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Teller Information Panel
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: purpleDark,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "TELLER 3",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "NOW SERVING",
                      style: GoogleFonts.poppins(
                        color: purpleLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Den Karryl",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "SQ092",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 32),
                    DetailRow(
                      label: "Appointment ID",
                      value: "APT122",
                      labelColor: purpleLight,
                      valueColor: Colors.white,
                    ),
                    DetailRow(
                      label: "Estimated Time",
                      value: "45 mins",
                      labelColor: purpleLight,
                      valueColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Service Needed",
                        style: GoogleFonts.poppins(
                          color: purpleLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Report Lost/Stolen Card",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PurpleButton(
                            label: "View Appointment",
                            purpleMid: purpleMid,
                            onPressed: () {}),
                        const SizedBox(width: 24),
                        PurpleButton(
                            label: "Next",
                            purpleMid: purpleMid,
                            onPressed: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sidebar navigation item widget
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
    final iconColor = textColor;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          fontSize: 14,
          color: textColor,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ArchivesPage()),
        ); // Close drawer on mobile
      },
    );
  }
}

// Dropdown filter widget
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
                fontSize: 12,
              ),
            ),
          ),
          onChanged: (String? newValue) {
            if (newValue != null) setState(() => dropdownValue = newValue);
          },
          items: <String>['Regular', 'Priority']
              .map<DropdownMenuItem<String>>(
                (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e, style: GoogleFonts.poppins(fontSize: 12))),
              )
              .toList(),
        ),
      ),
    );
  }
}

// Queue card widget
class QueueCard extends StatelessWidget {
  final String name;
  final String queueID;
  final String appointmentID;
  final String serviceNeeded;
  final Color purpleMid;

  const QueueCard({
    super.key,
    required this.name,
    required this.queueID,
    required this.appointmentID,
    required this.serviceNeeded,
    required this.purpleMid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: purpleMid.withOpacity(0.15),
        border: Border.all(color: purpleMid),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: purpleMid.darken(0.2),
            ),
          ),
          const SizedBox(height: 6),
          InfoRowLabelValue(
              label: "Queue ID:", value: queueID, purpleMid: purpleMid),
          InfoRowLabelValue(
              label: "Appointment ID:",
              value: appointmentID,
              purpleMid: purpleMid),
          InfoRowLabelValue(
              label: "Service Needed:",
              value: serviceNeeded,
              purpleMid: purpleMid),
        ],
      ),
    );
  }
}

class InfoRowLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final Color purpleMid;

  const InfoRowLabelValue({
    super.key,
    required this.label,
    required this.value,
    required this.purpleMid,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.black,
          ),
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

// Detail row for info panel
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: labelColor,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: valueColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Purple styled button
class PurpleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color purpleMid;

  const PurpleButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.purpleMid,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: purpleMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}

// Extension method to darken color
extension ColorShading on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
