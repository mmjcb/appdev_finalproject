import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page'), leading: Icon(Icons.home)),
      body: const Center(
        child: Text('Ito ay Home Page!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
