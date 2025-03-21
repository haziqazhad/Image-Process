import 'package:flutter/material.dart';

class GuidelinesPage extends StatefulWidget {
  const GuidelinesPage({super.key});

  @override
  _GuidelinesPageState createState() => _GuidelinesPageState();
}

class _GuidelinesPageState extends State<GuidelinesPage> {
  // List of image paths and descriptions for the "Crack" slider
  final List<Map<String, String>> crackImages = [
    {'image': 'assets/guidlines/crack1.jpg', 'text': 'Crack Interface'},
    {
      'image': 'assets/guidlines/crack2.jpg',
      'text': 'click "Select" button to choose image'
    },
    {
      'image': 'assets/guidlines/crack3.jpg',
      'text': 'click "Gray" button to convert to gray'
    },
    {
      'image': 'assets/guidlines/crack4.jpg',
      'text': 'click "B&W" button to detect the crack number'
    },
    {
      'image': 'assets/guidlines/crack5.jpg',
      'text': 'click "Save" button to save the image'
    },
  ];

  // List of image paths and descriptions for the "Noise" slider
  final List<Map<String, String>> noiseImages = [
    {'image': 'assets/guidlines/noise1.jpg', 'text': 'Noise Interface'},
    {
      'image': 'assets/guidlines/noise2.jpg',
      'text': 'click "Select" button to choose image'
    },
    {
      'image': 'assets/guidlines/noise3.jpg',
      'text':
          'move the circle slider to control noise, then click "Filter" button to filter image'
    },
    {
      'image': 'assets/guidlines/noise4.jpg',
      'text': 'click "Save" button to save the image'
    },
  ];

  // A variable to track which slider (Crack or Noise) is displayed
  bool isCrackSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guidelines',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24.0, // Set the desired font size here
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 25, 120, 87),
        actions: [
          // Button for "Crack" section
          IconButton(
            icon: Icon(
              Icons.image,
              color: isCrackSelected
                  ? Colors.white
                  : Colors.white70, // Change color when selected
            ),
            onPressed: () {
              setState(() {
                isCrackSelected = true;
              });
            },
          ),
          // Button for "Noise" section
          IconButton(
            icon: Icon(
              Icons.volume_up,
              color: !isCrackSelected
                  ? Colors.white
                  : Colors.white70, // Change color when selected
            ),
            onPressed: () {
              setState(() {
                isCrackSelected = false;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Displaying the selected slider based on isCrackSelected
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              isCrackSelected ? 'Crack' : 'Noise',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.height *
                  0.6, // Set height to 60% of the screen height
              child: PageView.builder(
                itemCount:
                    isCrackSelected ? crackImages.length : noiseImages.length,
                itemBuilder: (context, index) {
                  final item =
                      isCrackSelected ? crackImages[index] : noiseImages[index];
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Center the image vertically and horizontally
                      Center(
                        child: Image.asset(
                          item['image']!,
                          fit: BoxFit
                              .contain, // Image will maintain aspect ratio and fit within the container
                          height: MediaQuery.of(context).size.height *
                              0.5, // Adjust the height as needed (50% of screen height)
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Container(
                          width: double.infinity,
                          color: Colors.black.withOpacity(0.6),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item['text']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
