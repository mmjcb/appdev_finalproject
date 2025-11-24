import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

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
  final _passwordController = TextEditingController();
  final _contactNumController = TextEditingController();

  final _streetController = TextEditingController();
  final _barangayController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _cityProController = TextEditingController();

  final _dobController = TextEditingController();
  String? _selectedSex;

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _midController.dispose();
    _extController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _contactNumController.dispose();
    _streetController.dispose();
    _barangayController.dispose();
    _municipalityController.dispose();
    _cityProController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  InputDecoration _thinBorderDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1, color: Colors.black54),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1, color: Colors.black38),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1.5, color: Colors.purple),
      ),
    );
  }

  void _registerUser() async {
    if (_fnameController.text.isEmpty ||
        _lnameController.text.isEmpty ||
        _midController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _contactNumController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _selectedSex == null ||
        _streetController.text.isEmpty ||
        _barangayController.text.isEmpty ||
        _municipalityController.text.isEmpty ||
        _cityProController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    try {
      // Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Firestore save
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': _fnameController.text,
        'lastName': _lnameController.text,
        'middleInitial': _midController.text,
        'ext': _extController.text,
        'email': _emailController.text,
        'contact': _contactNumController.text,
        'dob': _dobController.text,
        'sex': _selectedSex,
        'address': {
          'street': _streetController.text,
          'barangay': _barangayController.text,
          'municipality': _municipalityController.text,
          'cityProvince': _cityProController.text,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registration failed")),
      );
    }
  }

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
              children: [
                const SizedBox(height: 30),
                Image.asset('assets/SkipQ-Logo.png', height: 80),
                const SizedBox(height: 8),

                Text(
                  "Create Account",
                  style: GoogleFonts.audiowide(
                    fontSize: 26,
                    color: Color(0xFF543063),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // MAIN CONTAINER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.40),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.50)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PERSONAL INFO
                        Text(
                          'Personal Information',
                          style: GoogleFonts.audiowide(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF543063)),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _fnameController,
                                decoration:
                                    _thinBorderDecoration('First Name'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _midController,
                                decoration: _thinBorderDecoration('M.I.'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _lnameController,
                                decoration:
                                    _thinBorderDecoration('Last Name'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _extController,
                                decoration: _thinBorderDecoration('Ext.'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _dobController,
                                readOnly: true,
                                decoration: _thinBorderDecoration('Date of Birth')
                                    .copyWith(
                                        suffixIcon:
                                            const Icon(Icons.calendar_today)),
                                onTap: () async {
                                  DateTime? pickedDate =
                                      await showDatePicker(
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
                                decoration: _thinBorderDecoration('Sex'),
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

                        const SizedBox(height: 25),

                        // ADDRESS
                        Text(
                          'Complete Address',
                          style: GoogleFonts.audiowide(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF543063)),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _streetController,
                                decoration:
                                    _thinBorderDecoration('Street'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _barangayController,
                                decoration:
                                    _thinBorderDecoration('Barangay'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _municipalityController,
                                decoration:
                                    _thinBorderDecoration('Municipality'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _cityProController,
                                decoration:
                                    _thinBorderDecoration('City/Province'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // ACCOUNT INFO — NOW LAST
                        Text(
                          'Account Information',
                          style: GoogleFonts.audiowide(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF543063)),
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _contactNumController,
                          decoration:
                              _thinBorderDecoration('Contact Number'),
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _emailController,
                          decoration:
                              _thinBorderDecoration('Email Address'),
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration:
                              _thinBorderDecoration('Password'),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFEABDE6),
                              foregroundColor: Colors.black,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color:
                                        Color.fromARGB(128, 170, 96, 200)),
                              ),
                            ),
                            onPressed: _registerUser,
                            child: const Text(
                              "Create Account",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
