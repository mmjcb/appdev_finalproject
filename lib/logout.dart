import 'package:flutter/material.dart';
import 'login.dart';

class Logout {
  /// Call this method to show a confirmation dialog and logout if confirmed
  static void performLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must choose an option
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // close the dialog
              },
            ),
            TextButton(
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                // Clear navigation stack and go to Login page
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const Login()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
