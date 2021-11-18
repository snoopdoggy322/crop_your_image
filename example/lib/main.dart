import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: ColorefulScreenCrop(),
      ),
    );
  }
}

class ColorefulScreenCrop extends StatefulWidget {
  const ColorefulScreenCrop();

  @override
  _ColorefulScreenCropState createState() => _ColorefulScreenCropState();
}

class _ColorefulScreenCropState extends State<ColorefulScreenCrop> {
  final _controller = CropController();
  late final Uint8List imageData;
  var _isProcessing = false;
  Rect cropRect = Rect.zero;

  set isProcessing(bool value) {
    setState(() {
      _isProcessing = value;
    });
  }

  Uint8List? _croppedData;

  set croppedData(Uint8List? value) {
    setState(() {
      _croppedData = value;
    });
  }

  @override
  void initState() {
    http
        .get(Uri.parse(
            'https://store-images.s-microsoft.com/image/apps.20866.9007199266667349.cd06b2b0-d415-4f7a-bcc8-c9db870a0c97.4b4a0d1e-e2ee-45dc-9a18-77fa30eb8b25?w=672&h=378&q=80&mode=letterbox&background=%23FFE4E4E4&format=jpg'))
        .then((value) {
      setState(() {
        imageData = value.bodyBytes;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade50,
        title: Text(
          'test',
          style: TextStyle(color: Colors.blue),
        ),
        actions: [
          if (_croppedData == null)
            IconButton(
              icon: Icon(Icons.cut),
              onPressed: () {
                isProcessing = true;
                _controller.crop();
              },
            ),
          if (_croppedData != null)
            IconButton(
              icon: Icon(Icons.redo),
              onPressed: () => croppedData = null,
            ),
        ],
        iconTheme: IconThemeData(
          color: Colors.blue,
        ),
      ),
      body: Visibility(
        visible: imageData.isNotEmpty && !_isProcessing,
        child: imageData.isNotEmpty
            ? Visibility(
                visible: _croppedData == null,
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      child: Crop(
                        controller: _controller,
                        image: imageData,
                        onCropped: (cropped) {
                          croppedData = cropped;
                          isProcessing = false;
                        },
                        initialSize: 1,
                        cornerDotBuilder: (size, cornerIndex) => DotControl(
                          color: const [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.transparent,
                          ][cornerIndex.index],
                        ),
                        aspectRatio: 1,
                        borderRadius: Radius.circular(32),
                        withCircleUi: false,
                        onRect: (Rect r) {
                          setState(() {
                            cropRect = r;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: PartImagePainter(
                              rect: cropRect,
                              image: imageData,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: PartImagePainter(
                              rect: cropRect,
                              image: imageData,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                replacement: _croppedData != null
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        height: double.infinity,
                        width: double.infinity,
                        child: Image.memory(
                          _croppedData!,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const SizedBox.shrink(),
              )
            : const SizedBox.shrink(),
        replacement: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class MyClip extends CustomClipper<Rect> {
  final Rect rect;

  MyClip(this.rect);

  Rect getClip(Size size) {
    return rect;
  }

  bool shouldReclip(oldClipper) {
    return true;
  }
}
