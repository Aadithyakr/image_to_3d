import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class ShapeDetectionPage extends StatefulWidget {
  final File imageFile;

  const ShapeDetectionPage({super.key, required this.imageFile});

  @override
  _ShapeDetectionPageState createState() => _ShapeDetectionPageState();
}

class _ShapeDetectionPageState extends State<ShapeDetectionPage> {
  Uint8List? convertedImage;
  String detectedShape = '';

  @override
  void initState() {
    super.initState();
    convertImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: convertedImage == null
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.memory(convertedImage!),
                    const SizedBox(height: 20),
                    Text(
                      detectedShape.isNotEmpty
                          ? 'Detected Shape: $detectedShape'
                          : 'Identifying shape...',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> convertImage() async {
    final List<int> bytes = await widget.imageFile.readAsBytes();
    img.Image originalImage = img.decodeImage(Uint8List.fromList(bytes))!;

    img.Image grayscaleImage = img.grayscale(originalImage);
    img.Image edgeDetectedImage = img.sobel(grayscaleImage);
    Uint8List sketchBytes =
        Uint8List.fromList(img.encodeJpg(edgeDetectedImage));

    setState(() {
      convertedImage = sketchBytes;
    });

    detectShape(edgeDetectedImage);
  }

  void detectShape(img.Image edgeImage) {
    // Here you would implement shape detection logic, potentially using contours
    // For simplicity, you might want to start by just analyzing pixel values
    // and approximating shapes based on edge detection results.
  }
}
