import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _midController = TextEditingController();
  final _extController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactNumController = TextEditingController();
  final _streetController = TextEditingController();
  final _barangayController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _cityProController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedSex; // No default selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(162, 234, 189, 230), Color(0xFFD69ADE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Image.asset(
                    'assets/SkipQ-Logo.png',
                    height: 80,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create Account",
                  style: GoogleFonts.audiowide(
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF543063),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Lorem ipsum dolor sit amet, \nconsectetur adipiscing elit.",
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                Container(
                  width: 400,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: GoogleFonts.audiowide(
                          fontSize: 18,
                          color: const Color(0xFF543063),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _fnameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _midController,
                                decoration: InputDecoration(
                                  labelText: 'M.I.',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _lnameController,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _extController,
                                decoration: InputDecoration(
                                  labelText: 'Ext.',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _dobController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      _dobController.text =
                                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Sex',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                value: _selectedSex,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Male', child: Text('Male')),
                                  DropdownMenuItem(
                                      value: 'Female', child: Text('Female')),
                                  DropdownMenuItem(
                                      value: 'Other', child: Text('Other')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSex = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Contact Information',
                        style: GoogleFonts.audiowide(
                          fontSize: 18,
                          color: const Color(0xFF543063),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: TextFormField(
                          controller: _contactNumController,
                          decoration: InputDecoration(
                            labelText: 'Contact Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Complete Address',
                        style: GoogleFonts.audiowide(
                          fontSize: 18,
                          color: const Color(0xFF543063),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _streetController,
                                decoration: InputDecoration(
                                  labelText: 'Street',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _barangayController,
                                decoration: InputDecoration(
                                  labelText: 'Barangay',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _municipalityController,
                                decoration: InputDecoration(
                                  labelText: 'Municipality',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _cityProController,
                                decoration: InputDecoration(
                                  labelText: 'City/Province',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEABDE6),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Color.fromARGB(128, 170, 96, 200),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()),
                            );
                          },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      },
                      child: const Text(
                        "Log in",
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
