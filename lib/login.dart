import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool rememberMe = false;

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
                  "Log In",
                  style: GoogleFonts.audiowide(
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF543063),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Lorem ipsum dolor sit amet, \nconsectetur adipiscing elit.",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

                // Added horizontal padding here 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.40),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.50)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding:
                              const EdgeInsets.only(top: 20.0, bottom: 10.0),
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            obscureText: true,
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (value) {
                                    setState(() => rememberMe = value ?? false);
                                  },
                                  activeColor: Colors.purple,
                                ),
                                const Text("Remember Me"),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Forgot Password",
                                style: TextStyle(color: Colors.purple),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
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
                    const Text("Don’t have an account yet? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Register(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 400,
                  child: const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 400,
                  child: Column(
                    children: [
                      socialButton('assets/google.png', "Sign in with Google"),
                      socialButton('assets/facebook.png', "Sign in with Facebook"),
                      socialButton('assets/apple.png', "Sign in with Apple"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget socialButton(String imagePath, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: Image.asset(
            imagePath,
            height: 24,
            width: 24,
          ),
          label: Text(
            text,
            style: const TextStyle(color: Colors.black),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Colors.black38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
