import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  late File _image;
  late List _output;
  final imagepicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadmodel().then((_) => setState(() {}));
  }

  detectimage(File image) async {
    var prediction = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _output = prediction ?? [];
      loading = false;
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  pickimage_gallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    _image = File(image.path);
    detectimage(_image);
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ML Classifier',
          style: GoogleFonts.roboto(),
        ),
      ),
      body: SizedBox(
        height: h,
        width: w,
        child: Column(
          children: [
            Container(
              height: 150,
              width: 150,
              padding: const EdgeInsets.all(10),
              child: const Icon(
                Icons.masks,
                size: 150,
              ),
            ),
            Container(
              child: Text(
                'Mask Detector',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Container(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: pickimage_gallery,
                      child: Text(
                        'Gallery',
                        style: GoogleFonts.roboto(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!loading)
              Container(
                child: Column(
                  children: [
                    Container(
                      height: 220,
                      padding: const EdgeInsets.all(15),
                      child: Image.file(_image),
                    ),
                    if (_output.isNotEmpty)
                      Text(
                        _output[0]['label'].toString().substring(2),
                        style: GoogleFonts.roboto(fontSize: 18),
                      ),
                    if (_output.isNotEmpty)
                      Text(
                        'Confidence: ${_output[0]['confidence']}',
                        style: GoogleFonts.roboto(fontSize: 18),
                      )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
