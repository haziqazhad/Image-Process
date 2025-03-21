import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class CrackPage extends StatefulWidget {
  const CrackPage({super.key});

  @override
  State<CrackPage> createState() => _CrackPageState();
}

class _CrackPageState extends State<CrackPage> {
  PlatformFile? pickedFile;
  Uint8List? grayscaleImage;
  Uint8List? blackAndWhiteImage;
  Uint8List? invertedImage;
  int connectedWhiteLines = 0;

  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        pickedFile = result.files.single;
        grayscaleImage = null;
        blackAndWhiteImage = null;
        invertedImage = null;
        connectedWhiteLines = 0;
      });
    }
  }

  void _processToGrayscale() async {
    if (pickedFile == null || pickedFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first!')),
      );
      return;
    }

    final imageBytes = File(pickedFile!.path!).readAsBytesSync();
    final image = img.decodeImage(imageBytes);

    if (image != null) {
      final grayscale = img.grayscale(image);

      setState(() {
        grayscaleImage = Uint8List.fromList(img.encodeJpg(grayscale));
        blackAndWhiteImage = null;
        invertedImage = null;
        connectedWhiteLines = 0;
      });
    }
  }

  void _processAndInvertBlackAndWhite() {
    if (grayscaleImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please convert the image to grayscale first!')),
      );
      return;
    }

    final image = img.decodeImage(grayscaleImage!);

    if (image != null) {
      const threshold = 128;

      // Step 1: Convert to black and white
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final luminance = img.getLuminance(pixel);

          final newPixel = luminance > threshold
              ? img.ColorRgb8(255, 255, 255)
              : img.ColorRgb8(0, 0, 0);

          image.setPixel(x, y, newPixel);
        }
      }

      // Step 2: Invert the black-and-white image
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final luminance = img.getLuminance(pixel);

          final invertedPixel = luminance == 255
              ? img.ColorRgb8(0, 0, 0) // Invert white to black
              : img.ColorRgb8(255, 255, 255); // Invert black to white;

          image.setPixel(x, y, invertedPixel);
        }
      }

      // Step 3: Perform Connected Component Labeling to count and filter cracks
      final visited =
          List.generate(image.height, (_) => List.filled(image.width, false));
      int crackCount = 0;

      void dfs(int x, int y) {
        // Boundary check
        if (x < 0 || y < 0 || x >= image.width || y >= image.height) return;

        // Check if pixel is already visited or not white
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        if (visited[y][x] || luminance != 255) return;

        // Mark pixel as visited
        visited[y][x] = true;

        // Recursively visit all 8 neighboring pixels
        dfs(x + 1, y); // Right
        dfs(x - 1, y); // Left
        dfs(x, y + 1); // Down
        dfs(x, y - 1); // Up
        dfs(x + 1, y + 1); // Bottom-right
        dfs(x - 1, y + 1); // Bottom-left
        dfs(x + 1, y - 1); // Top-right
        dfs(x - 1, y - 1); // Top-left
      }

      // Step 4: Iterate over all pixels to detect cracks
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final luminance = img.getLuminance(pixel);
          if (!visited[y][x] && luminance == 255) {
            // Start a new DFS for each unvisited white pixel
            dfs(x, y);
            crackCount++;
          }
        }
      }

      setState(() {
        blackAndWhiteImage = Uint8List.fromList(img.encodeJpg(image));
        invertedImage = blackAndWhiteImage; // Single output
        connectedWhiteLines = crackCount; // Update crack count
      });
    }
  }

  Future<void> saveToDownloads() async {
    try {
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download folder not found.')),
        );
        return;
      }

      final filePath = '${directory.path}/Crack_image.jpg';

      if (invertedImage != null) {
        final file = File(filePath);
        await file.writeAsBytes(invertedImage!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to Downloads: $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No processed image to save.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crack Detection', // Add the title text
          style: TextStyle(
            fontSize: 25, // Adjust the font size as needed
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 25, 120, 87),
          ),
        ),
      ),
      body: Column(
        children: [
          // Center the buttons and crack count display box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the row items
                children: [
                  // Box to contain the buttons
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    width: 170,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: selectFile,
                          icon: const Icon(Icons.file_open),
                          label: const Text('Select'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(500, 50),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _processToGrayscale,
                          icon: const Icon(Icons.looks_one),
                          label: const Text('Gray'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(500, 50),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _processAndInvertBlackAndWhite,
                          icon: const Icon(Icons.looks_two),
                          label: const Text('B&W'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(500, 50),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: saveToDownloads,
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(500, 50),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      width:
                          20), // Space between buttons box and crack count box
                  // Box to contain the crack count display
                  Container(
                    alignment: Alignment.center,
                    width: 170, // Adjusted width for better spacing
                    height: 150, // Adjusted height for better spacing
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Column(
                      // Use Column to stack text vertically
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Number of Crack:', // Add the title text
                          style: TextStyle(
                            fontSize: 18, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 25, 120, 87),
                          ),
                        ),
                        SizedBox(height: 8), // Add some spacing
                        Text(
                          '$connectedWhiteLines', // Crack count
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 25, 120, 87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom space for image preview or prompt
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: pickedFile != null
                  ? (invertedImage != null
                      ? Image.memory(invertedImage!)
                      : (blackAndWhiteImage != null
                          ? Image.memory(blackAndWhiteImage!)
                          : (grayscaleImage != null
                              ? Image.memory(grayscaleImage!)
                              : Image.file(File(pickedFile!.path!)))))
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.all(80),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(255, 25, 120, 87),
                              width: 2),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(255, 214, 225, 219)
                              .withOpacity(0.2),
                        ),
                        child: Text(
                          'Choose an image to detect cracks',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
