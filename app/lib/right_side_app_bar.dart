import 'package:app/guideline.dart';
import 'package:flutter/material.dart';

class RightSideAppBar extends StatelessWidget {
  const RightSideAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          // When the side bar is tapped, push the GuidelinesPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GuidelinesPage()),
          );
        },
        child: Container(
          width: 180, // Adjust the width as needed
          height: 60, // Height of the app bar
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 25, 120, 87), // Background color
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30), // Curved bottom left corner
              topLeft: Radius.circular(30), // Curved top left corner
            ),
          ),
          child: Center(
            child: Text(
              'Guidelines', // Change the text if needed
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
