import 'package:flutter/material.dart';
import 'crack_page.dart';
import 'noise_reduction_page.dart';
import 'right_side_app_bar.dart'; // Import the RightSideAppBar

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white, // Set primary color to white
        scaffoldBackgroundColor:
            Colors.white, // Set scaffold background color to white
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Set AppBar background color to white
          iconTheme:
              IconThemeData(color: Colors.black), // Set AppBar icon color
          titleTextStyle:
              TextStyle(color: Colors.black), // Set AppBar title text color
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor:
              Color.fromARGB(255, 25, 120, 87), // Bottom navigation bar color
          selectedItemColor: Colors.white, // Color for selected item
          unselectedItemColor: Colors.grey, // Color for unselected items
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onBottomNavigationBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static final List<Widget> _pages = [
    const CrackPage(),
    const NoiseReductionPage(), // Ensure this page exists
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex], // Display the selected page
          const RightSideAppBar(), // Add the right-side app bar
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.electric_bolt),
            label: 'Crack Detection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.noise_aware),
            label: 'Noise Reduction',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onBottomNavigationBarTapped,
      ),
    );
  }
}
