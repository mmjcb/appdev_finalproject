import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentViewModal extends StatelessWidget {
  final String docId;

  const AppointmentViewModal({super.key, required this.docId});

  // --- Color Definitions ---
  static const Color primaryPurple = Color(0xFF6A1B9A); // Dark Purple
  static const Color ticketPurple = Color(0xFF9C27B0); // Mid-Tone Purple (for ticket text)
  static const Color frameColor = Color(0xFFD1C4E9); // Outer border
  // static const Color queueBgColor = Color(0xFFF3E5F5); // No longer needed

  String formatDateTime(dynamic dateTime) {
    try {
      if (dateTime is DateTime) {
        return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
      }
      if (dateTime is String) {
        return DateFormat('MMM dd, yyyy - hh:mm a')
            .format(DateTime.parse(dateTime));
      }
      if (dateTime is Timestamp) {
        return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime.toDate());
      }
      return "Unknown";
    } catch (e) {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Outer container for the dialog with white background and colored border
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: frameColor, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection("appointments").doc(docId).get(),
        builder: (context, appointmentSnapshot) {
          if (appointmentSnapshot.connectionState == ConnectionState.waiting) {
            return _loading();
          }

          if (!appointmentSnapshot.hasData || !appointmentSnapshot.data!.exists) {
            return _error("Appointment not found.");
          }

          final appointmentData =
              appointmentSnapshot.data!.data() as Map<String, dynamic>;
          final userId = appointmentData['userId'];

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return _loading();
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return _error("User not found.");
              }

              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
              final firstName = userData['firstName'] ?? 'User';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _modalContent(context, appointmentData, firstName),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _loading() {
    return const SizedBox(
      height: 300,
      child: Center(
        child: CircularProgressIndicator(color: primaryPurple),
      ),
    );
  }

  Widget _error(String message) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Text(message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.red)),
      ),
    );
  }

  Widget _modalContent(BuildContext context,
      Map<String, dynamic> appointmentData, String firstName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title Header
        Text(
          "Hi, $firstName!",
          style: GoogleFonts.poppins(
              fontSize: 32, fontWeight: FontWeight.bold, color: primaryPurple),
        ),
        const SizedBox(height: 8),
        Text(
          "Your appointment number is",
          style: GoogleFonts.poppins(
              fontSize: 16, color: primaryPurple.withOpacity(0.8)),
        ),
        const SizedBox(height: 16),

        // 🎟️ Ticket Design (Appointment Number)
        _TicketShape(
          child: Text(
            appointmentData["appointmentnum"] ?? "SQ092",
            style: GoogleFonts.poppins(
                fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ),
        const SizedBox(height: 32),

        // 🐰 NEW: Queue Number and Bunny (Centered, side-by-side, no background)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Text
            Text(
              "Your position in queue",
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: primaryPurple),
            ),
            const SizedBox(height: 12),

            // Bunny Image and Queue Number (Side-by-side and centered)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Bunny Image
                Image.asset(
                  "assets/bunny-ticket.png",
                  height: 100, // Reduced height for better side-by-side fit
                ),
                const SizedBox(width: 16),
                // Queue Number
                Text(
                  "${appointmentData['queuenum'] ?? '11'}",
                  style: GoogleFonts.poppins(
                    fontSize: 72, // Slightly increased size
                    fontWeight: FontWeight.bold,
                    color: ticketPurple,
                    height: 1.0, // Control line spacing
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Appointment Date/Time
        _InfoTile(
          title: "Scheduled Appointment Time",
          value: formatDateTime(appointmentData['appointmentdate']),
          icon: Icons.calendar_month,
        ),

        const SizedBox(height: 32),

        // Bottom message
        Text(
          "Please arrive 15 minutes before your scheduled time to prepare for your appointment.",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // A helper widget for the information tiles (date/time, etc.)
  Widget _InfoTile({required String title, required String value, required IconData icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: primaryPurple, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }

  // 🎫 Custom Widget for the Ticket Shape (without the stub/hashtag icon)
  Widget _TicketShape({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: ticketPurple,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(width: 20),
            Container(
              height: 40,
              width: 2,
              // Simple dotted line simulation for perforation
              child: CustomPaint(
                painter: _DottedLinePainter(ticketPurple.withOpacity(0.5)),
              ),
            ),
            // No trailing SizedBox/Icon for the ticket stub
          ],
        ),
      ),
    );
  }

  // -------------------- Show Dialog --------------------
  static Future<void> show(BuildContext context, String docId) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // prevent closing when tap inside
              child: AppointmentViewModal(docId: docId),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for a simple vertical dotted line
class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    double startY = 0.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round;

    while (startY < size.height) {
      canvas.drawLine(Offset(size.width / 2, startY),
          Offset(size.width / 2, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}