import 'dart:io';
import 'dart:typed_data';
import 'package:app/circularslider.dart'; // Import the CircularSlider
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class NoiseReductionPage extends StatefulWidget {
  const NoiseReductionPage({super.key});

  @override
  State<NoiseReductionPage> createState() => _NoiseReductionPageState();
}

class _NoiseReductionPageState extends State<NoiseReductionPage> {
  PlatformFile? pickedFile;
  Uint8List? filteredImage;
  double sliderValue = 0.0; // Slider value for noise control

  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        pickedFile = result.files.single;
        filteredImage = null;
        sliderValue = 0.0; // Reset slider value
      });
    }
  }

  void _processAndFilterNoise() async {
    if (pickedFile == null || pickedFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first!')),
      );
      return;
    }

    final imageBytes = File(pickedFile!.path!).readAsBytesSync();
    final image = img.decodeImage(imageBytes);

    if (image != null) {
      final noiseLevel = (sliderValue / 100).clamp(0.0, 1.0);

      // Apply median filter for salt-and-pepper noise reduction
      final filtered =
          img.gaussianBlur(image, radius: (5 * noiseLevel).toInt());

      setState(() {
        filteredImage = Uint8List.fromList(img.encodeJpg(filtered));
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

      final filePath = '${directory.path}/Filtered_image.jpg';

      if (filteredImage != null) {
        final file = File(filePath);
        await file.writeAsBytes(filteredImage!);

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
          'Noise Reduction',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 25, 120, 87),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content vertically
          children: [
            // Add SizedBox for vertical spacing
            SizedBox(height: 30), // Adjust the value as needed

            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Button and Slider Box
                  Container(
                    padding: const EdgeInsets.all(5.0),
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
                          onPressed: _processAndFilterNoise,
                          icon: const Icon(Icons.filter_alt),
                          label: const Text('Filter'),
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
                  const SizedBox(width: 10),
                  // Circular Slider Box
                  Container(
                    alignment: Alignment.center,
                    width: 170,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Noise Control: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 25, 120, 87),
                          ),
                        ),
                        SizedBox(height: 10),
                        CircularSlider(
                          min: 0,
                          max: 100,
                          initialValue: sliderValue,
                          onChanged: (double value) {
                            setState(() {
                              sliderValue = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 35), // Adjust the value as needed
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: pickedFile != null
                  ? (filteredImage != null
                      ? Image.memory(filteredImage!)
                      : Image.file(File(pickedFile!.path!)))
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
                          'Choose an image to Filter Noise',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
