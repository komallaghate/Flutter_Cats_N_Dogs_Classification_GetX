import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  late File _image;
  late List _output;
  final picker = ImagePicker();

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 1,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _output = output!;
      _loading = false;
    });
  }

  captureImagePhoneCamera() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
    detectImage(_image);
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    detectImage(_image);
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'aeets/labels.txt');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal,
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 10.0),
                  const Center(
                    child: Text(
                      'Cats & Dogs Detector Application GetX',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0),
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  Center(
                    child: _loading
                        ? Container(
                            width: 350.0,
                            child: Column(children: <Widget>[
                              Image.asset(
                                  'assets/image_Cat_dog_Background.jpg'),
                              const SizedBox(height: 47.0),
                            ]))
                        : Container(
                            child: Column(
                            children: <Widget>[
                              Container(
                                height: 280.0,
                                child: Image.file(_image),
                              ),
                              const SizedBox(height: 22.0),
                              _output != null
                                  ? Text('${_output[0]['label']}',
                                      style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25.0,
                                      ))
                                  : Container(),
                              const SizedBox(height: 22.0),
                            ],
                          )),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                captureImagePhoneCamera();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width - 250,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 15.0),
                                decoration: BoxDecoration(
                                    color: Colors.pink,
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: const Text(
                                  'Camera',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                ),
                              )),
                          const SizedBox(height: 5.0),
                          GestureDetector(
                              onTap: () {
                                pickGalleryImage();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width - 250,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 15.0),
                                decoration: BoxDecoration(
                                    color: Colors.pink,
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: const Text(
                                  'Gallery',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                ),
                              )),
                        ],
                      ))
                ])));
  }
}
