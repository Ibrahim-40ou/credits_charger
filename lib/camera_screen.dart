import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  Future<XFile?> takePicture() async {
    XFile file = await controller.takePicture();
    return file;
  }

  String scannedText = '';
  bool allDigits(String letters) {
    for (int i = 0; i < letters.length; i++) {
      if (int.tryParse(letters[i]) == null) {
        return false;
      }
    }
    return true;
  }

  Future<String?> recognizeText(String path) async {
    try {
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(
        InputImage.fromFilePath(path),
      );
      List<String> hello = recognizedText.text.split('\n');
      for (int i = 0; i < hello.length; i++) {
        if (allDigits(hello[i])) {
          setState(() {
            scannedText = hello[i];
          });
        }
      }
      return recognizedText.text;
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(controller),
          ),
          Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.46,
                color: Colors.black.withOpacity(0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.height * 0.05,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.height * 0.05,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.46,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.88,
            left: MediaQuery.of(context).size.width * 0.435,
            child: FloatingActionButton(
              elevation: 10,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.camera_alt,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () async {
                XFile file = await controller.takePicture();
                await recognizeText(file.path);
                final Uri url = Uri(
                  scheme: 'tel',
                  path: '*133*$scannedText#',
                );
                await launchUrl(url);
              },
            ),
          ),
        ],
      ),
    );
  }
}
