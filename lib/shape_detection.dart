import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_3d_converter/model_viewer_page.dart';
import 'dart:io';
import 'package:vector_math/vector_math_64.dart' as v;

class ShapeDetectionPage extends StatefulWidget {
  final File imageFile;

  const ShapeDetectionPage({super.key, required this.imageFile});

  @override
  ShapeDetectionPageState createState() => ShapeDetectionPageState();
}

class ShapeDetectionPageState extends State<ShapeDetectionPage> {
  Uint8List? convertedImage;
  img.Image? edgeDetectedImage;

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
                    ElevatedButton(
                      onPressed: () {
                        create3DModel();
                      },
                      child: const Text('Create 3D Model'),
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

    // Convert to grayscale and apply edge detection
    img.Image grayscaleImage = img.grayscale(originalImage);
    edgeDetectedImage = img.sobel(grayscaleImage); // Apply Sobel filter

    if (edgeDetectedImage != null) {
      Uint8List sketchBytes =
          Uint8List.fromList(img.encodeJpg(edgeDetectedImage!));

      setState(() {
        convertedImage = sketchBytes;
      });
    }
  }

  void create3DModel() {
    if (edgeDetectedImage == null) {
      return;
    }

    List<v.Vector3> vertices = [];
    List<int> indices = [];
    double depth = 10.0;

    int? width = edgeDetectedImage?.width;
    int? height = edgeDetectedImage?.height;

    if (width == null || height == null) {
      return;
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        img.Pixel? pixel = edgeDetectedImage?.getPixel(x, y);

        if (pixel == null) {
          continue;
        }

        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        if (r > 0 || g > 0 || b > 0) {
          vertices.add(v.Vector3(x.toDouble(), y.toDouble(), 0)); // Top vertex
          vertices.add(
              v.Vector3(x.toDouble(), y.toDouble(), -depth)); // Bottom vertex
        }
      }
    }

    for (int i = 0; i < vertices.length - width * 2; i += 2) {
      indices.add(i);
      indices.add(i + 1);
      indices.add(i + 2);

      indices.add(i + 1);
      indices.add(i + 3);
      indices.add(i + 2);
    }

    // Navigate to the 3D model viewer page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ModelViewerPage(
          vertices: vertices,
          indices: indices,
          polygons: [],
        ),
      ),
    );
  }
}
