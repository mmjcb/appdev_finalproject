import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'home.dart';
import 'appointment.dart';
import 'appointment_details.dart';
import 'profile.dart';
import 'login.dart';
// import 'register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SkipQApp());
}

class SkipQApp extends StatelessWidget {
  const SkipQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkipQ',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const Login(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Navigator key for the appointments tab
  final GlobalKey<NavigatorState> _appointmentNavKey =
      GlobalKey<NavigatorState>();

  late final List<Widget> _pages = [
    const HomePage(),
    Navigator(
      key: _appointmentNavKey,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        Widget page;
        switch (settings.name) {
          case '/institution_details':
            final args = settings.arguments as Map<String, dynamic>?;
            page = AppointmentDetailsPage(
              institutionName: args?['institutionName'] ?? 'Unknown',
              institutionType: args?['institutionType'] ?? 'Unknown',
            );
            break;
          case '/':
          default:
            page = const AppointmentPage();
        }
        return MaterialPageRoute(
          builder: (context) => page,
          settings: settings,
        );
      },
    ),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            selectedItemColor: Colors.purple,
            unselectedItemColor: Colors.grey,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today), label: 'Appointments'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
