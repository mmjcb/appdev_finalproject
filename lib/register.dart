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
  // Controllers
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _midController = TextEditingController();
  final _extController = TextEditingController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _contactNumController = TextEditingController();

  final _streetController = TextEditingController();
  final _barangayController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _cityProController = TextEditingController();

  final _dobController = TextEditingController();
  String? _selectedSex;

  // School Info
  final _collegeDeptController = TextEditingController();
  final _programController = TextEditingController();
  final _yearLevelController = TextEditingController();
  final _sectionController = TextEditingController();

  // Error messages
  String _fnameError = '';
  String _lnameError = '';
  String _midError = '';
  String _extError = '';
  String _dobError = '';
  String _sexError = '';
  String _streetError = '';
  String _barangayError = '';
  String _municipalityError = '';
  String _cityProError = '';
  String _collegeError = '';
  String _programError = '';
  String _yearLevelError = '';
  String _sectionError = '';
  String _contactError = '';
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  bool _submitted = false;

  // Regex helpers
  final RegExp _lettersOnly = RegExp(r'^[A-Za-z\s]+$');
  final RegExp _singleLetter = RegExp(r'^[A-Za-z]$');
  final RegExp _alnumSection = RegExp(r'^[A-Za-z0-9\s\-]+$');
  final RegExp _emailReg = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
      r"(?:\.[a-zA-Z]{2,})+$");
  final RegExp _digitsOnly = RegExp(r'^\d+$');

  void _validateAll() {
    if (!mounted) return; // prevent setState if widget disposed
    setState(() {
      // Personal Info
      final vFname = _fnameController.text.trim();
      _fnameError = (!_lettersOnly.hasMatch(vFname) && vFname.isNotEmpty)
          ? 'Only letters and spaces allowed'
          : (vFname.isEmpty && _submitted ? 'First name is required' : '');

      final vLname = _lnameController.text.trim();
      _lnameError = (!_lettersOnly.hasMatch(vLname) && vLname.isNotEmpty)
          ? 'Only letters and spaces allowed'
          : (vLname.isEmpty && _submitted ? 'Last name is required' : '');

      final vMid = _midController.text.trim();
      _midError = vMid.isNotEmpty && !_singleLetter.hasMatch(vMid)
          ? 'Middle initial must be a single letter'
          : '';

      final vExt = _extController.text.trim();
      _extError = vExt.isNotEmpty && !_lettersOnly.hasMatch(vExt)
          ? 'Extension must contain only letters'
          : '';

      final vDob = _dobController.text.trim();
      _dobError = vDob.isEmpty && _submitted ? 'Date of birth is required' : '';

      _sexError = (_selectedSex == null || _selectedSex!.isEmpty) && _submitted
          ? 'Sex is required'
          : '';

      // Address
      final vStreet = _streetController.text.trim();
      _streetError = ''; // optional field

      final vBarangay = _barangayController.text.trim();
      _barangayError =
          (!_lettersOnly.hasMatch(vBarangay) && vBarangay.isNotEmpty)
              ? 'Only letters allowed'
              : (vBarangay.isEmpty && _submitted ? 'Barangay is required' : '');

      final vMunicipality = _municipalityController.text.trim();
      _municipalityError =
          (!_lettersOnly.hasMatch(vMunicipality) && vMunicipality.isNotEmpty)
              ? 'Only letters allowed'
              : (vMunicipality.isEmpty && _submitted
                  ? 'Municipality is required'
                  : '');

      final vCityPro = _cityProController.text.trim();
      _cityProError = (!_lettersOnly.hasMatch(vCityPro) && vCityPro.isNotEmpty)
          ? 'Only letters allowed'
          : (vCityPro.isEmpty && _submitted
              ? 'City / Province is required'
              : '');

      // School Info
      final vCollege = _collegeDeptController.text.trim();
      _collegeError = (!_lettersOnly.hasMatch(vCollege) && vCollege.isNotEmpty)
          ? 'Only letters allowed'
          : (vCollege.isEmpty && _submitted
              ? 'College Department is required'
              : '');

      final vProgram = _programController.text.trim();
      _programError = (!_lettersOnly.hasMatch(vProgram) && vProgram.isNotEmpty)
          ? 'Only letters allowed'
          : (vProgram.isEmpty && _submitted ? 'Program is required' : '');

      final vYear = _yearLevelController.text.trim();
      _yearLevelError = vYear.isNotEmpty && !_digitsOnly.hasMatch(vYear)
          ? 'Must be numeric'
          : (vYear.isEmpty && _submitted
              ? 'Year level is required'
              : (vYear.isNotEmpty &&
                      (int.tryParse(vYear) == null ||
                          int.parse(vYear) < 1 ||
                          int.parse(vYear) > 9)
                  ? 'Year level must be 1-9'
                  : ''));

      final vSection = _sectionController.text.trim();
      _sectionError = (!_alnumSection.hasMatch(vSection) && vSection.isNotEmpty)
          ? 'Only letters, numbers, spaces allowed'
          : (vSection.isEmpty && _submitted ? 'Section is required' : '');

      // Account Info
      final vContact = _contactNumController.text.trim();
      _contactError =
          vContact.isNotEmpty && !RegExp(r'^\d{11}$').hasMatch(vContact)
              ? 'Must be 11 digits'
              : (vContact.isEmpty && _submitted ? 'Contact is required' : '');

      final vEmail = _emailController.text.trim();
      _emailError = vEmail.isNotEmpty && !_emailReg.hasMatch(vEmail)
          ? 'Invalid email'
          : (vEmail.isEmpty && _submitted ? 'Email is required' : '');

      final vPassword = _passwordController.text;
      _passwordError = vPassword.isNotEmpty && vPassword.length < 6
          ? 'Min 6 characters'
          : (vPassword.isEmpty && _submitted ? 'Password is required' : '');

      final vConfirm = _confirmPasswordController.text;
      _confirmPasswordError = vConfirm.isNotEmpty && vConfirm != vPassword
          ? 'Passwords do not match'
          : (vConfirm.isEmpty && _submitted ? 'Please re-enter password' : '');
    });
  }

  bool _allValid() {
    _validateAll();
    final errors = [
      _fnameError,
      _lnameError,
      _midError,
      _extError,
      _dobError,
      _sexError,
      _barangayError,
      _municipalityError,
      _cityProError,
      _collegeError,
      _programError,
      _yearLevelError,
      _sectionError,
      _contactError,
      _emailError,
      _passwordError,
      _confirmPasswordError
    ];
    return errors.every((e) => e.isEmpty);
  }

  void _registerUser() async {
    if (!mounted) return;
    setState(() {
      _submitted = true;
    });
    _validateAll();

    if (!_allValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fix the errors in the form")),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': _fnameController.text.trim(),
        'lastName': _lnameController.text.trim(),
        'middleInitial': _midController.text.trim(),
        'ext': _extController.text.trim(),
        'email': _emailController.text.trim(),
        'contact': _contactNumController.text.trim(),
        'dob': _dobController.text.trim(),
        'sex': _selectedSex,
        'address': {
          'street': _streetController.text.trim(),
          'barangay': _barangayController.text.trim(),
          'municipality': _municipalityController.text.trim(),
          'cityProvince': _cityProController.text.trim(),
        },
        'schoolInfo': {
          'collegeDepartment': _collegeDeptController.text.trim(),
          'program': _programController.text.trim(),
          'yearLevel': _yearLevelController.text.trim(),
          'section': _sectionController.text.trim(),
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registration failed")),
      );
    }
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

  Widget _errorText(String msg) {
    if (!_submitted && msg.contains('required')) return const SizedBox.shrink();
    if (msg.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        '* $msg',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(234, 189, 230, 0.64),
              Color(0xFFD69ADE),
            ],
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

                // ================= PERSONAL INFO =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: GoogleFonts.audiowide(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF543063)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _fnameController,
                                    decoration:
                                        _thinBorderDecoration('First Name'),
                                    onChanged: (_) => _validateAll(),
                                  ),
                                  _errorText(_fnameError),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _midController,
                                    decoration: _thinBorderDecoration(
                                        'M.I. (optional)'),
                                    onChanged: (_) => _validateAll(),
                                  ),
                                  _errorText(_midError),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _lnameController,
                                    decoration:
                                        _thinBorderDecoration('Last Name'),
                                    onChanged: (_) => _validateAll(),
                                  ),
                                  _errorText(_lnameError),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _extController,
                                    decoration: _thinBorderDecoration(
                                        'Ext. (optional)'),
                                    onChanged: (_) => _validateAll(),
                                  ),
                                  _errorText(_extError),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _dobController,
                                    readOnly: true,
                                    decoration:
                                        _thinBorderDecoration('Date of Birth')
                                            .copyWith(
                                      suffixIcon:
                                          const Icon(Icons.calendar_today),
                                    ),
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime(2000),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (pickedDate != null) {
                                        _dobController.text =
                                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                        _validateAll();
                                      }
                                    },
                                  ),
                                  _errorText(_dobError),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    decoration: _thinBorderDecoration('Sex'),
                                    value: _selectedSex != null &&
                                            ['Male', 'Female', 'Other']
                                                .contains(_selectedSex)
                                        ? _selectedSex
                                        : null,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'Male', child: Text('Male')),
                                      DropdownMenuItem(
                                          value: 'Female',
                                          child: Text('Female')),
                                      DropdownMenuItem(
                                          value: 'Other', child: Text('Other')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSex = value;
                                      });
                                      _validateAll();
                                    },
                                  ),
                                  _errorText(_sexError),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // ================= ADDRESS =================
                        Text(
                          'Complete Address',
                          style: GoogleFonts.audiowide(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF543063)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _streetController,
                                    decoration: _thinBorderDecoration(
                                        'Street (optional)'),
                                    onChanged: (_) => _validateAll(),
                                  ),
                                  _errorText(_streetError),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _barangayController,
                                    decoration:
                                        _thinBorderDecoration('Barangay'),
                                    onChanged: (_) => _validateAll(),
                                  ),
                                  _errorText(_barangayError),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _municipalityController,
                                    decoration:
                                        _thinBorderDecoration('Municipality'),
                                    onChanged: (_) => _validateAll(),
                                  ),
                                  _errorText(_municipalityError),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _cityProController,
                                    decoration:
                                        _thinBorderDecoration('City/Province'),
                                    onChanged: (_) => _validateAll(),
                                  ),
                                  _errorText(_cityProError),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // ================= SCHOOL INFO =================
                        Text(
                          'School Information',
                          style: GoogleFonts.audiowide(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF543063)),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _collegeDeptController,
                              decoration:
                                  _thinBorderDecoration('College Department'),
                              onChanged: (_) => _validateAll(),
                            ),
                            _errorText(_collegeError),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _programController,
                              decoration:
                                  _thinBorderDecoration('Program Enrolled'),
                              onChanged: (_) => _validateAll(),
                            ),
                            _errorText(_programError),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: _yearLevelController,
                                        decoration:
                                            _thinBorderDecoration('Year Level'),
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => _validateAll(),
                                      ),
                                      _errorText(_yearLevelError),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: _sectionController,
                                        decoration:
                                            _thinBorderDecoration('Section'),
                                        onChanged: (_) => _validateAll(),
                                      ),
                                      _errorText(_sectionError),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // ================= ACCOUNT INFO =================
                        Text(
                          'Account Information',
                          style: GoogleFonts.audiowide(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF543063)),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _contactNumController,
                              decoration:
                                  _thinBorderDecoration('Contact Number'),
                              keyboardType: TextInputType.phone,
                              onChanged: (_) => _validateAll(),
                            ),
                            _errorText(_contactError),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _emailController,
                              decoration:
                                  _thinBorderDecoration('Email Address'),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (_) => _validateAll(),
                            ),
                            _errorText(_emailError),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _passwordController,
                              decoration: _thinBorderDecoration('Password'),
                              obscureText: true,
                              onChanged: (_) => _validateAll(),
                            ),
                            _errorText(_passwordError),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration:
                                  _thinBorderDecoration('Re-enter Password'),
                              obscureText: true,
                              onChanged: (_) => _validateAll(),
                            ),
                            _errorText(_confirmPasswordError),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEABDE6),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                    color: Color.fromARGB(128, 170, 96, 200)),
                              ),
                            ),
                            onPressed: _registerUser,
                            child: const Text(
                              "Create Account",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
