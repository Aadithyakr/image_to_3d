import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as v;

class ModelViewerPage extends StatefulWidget {
  final List<v.Vector3> vertices;
  final List<int> indices;
  final List<List<int>> polygons;

  const ModelViewerPage({
    super.key,
    required this.vertices,
    required this.indices,
    required this.polygons,
  });

  @override
  _ModelViewerPageState createState() => _ModelViewerPageState();
}

class _ModelViewerPageState extends State<ModelViewerPage> {
  late String _modelUrl;

  @override
  void initState() {
    super.initState();
    _create3DModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model Viewer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _modelUrl.isEmpty
                  ? const CircularProgressIndicator()
                  : ModelViewer(
                      src: _modelUrl,
                      alt: '3D Model',
                      ar: true,
                      autoRotate: true,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _create3DModel() async {
    final glbData =
        await _createGlbFile(widget.vertices, widget.indices, widget.polygons);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/model.glb');
    await file.writeAsBytes(glbData);

    setState(() {
      _modelUrl = file.path;
    });
  }

  Future<Uint8List> _createGlbFile(List<v.Vector3> vertices, List<int> indices,
      List<List<int>> polygons) async {
    final glbData = Uint8List(1024);
    return glbData;
  }
}
