import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_collection_app/screens/thank_you.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../constants/values.dart';
import '../main.dart' show cameras;

class MouthCapture extends StatefulWidget {
  MouthCapture({Key key, @required this.entryUid}) : super(key: key);

  final String entryUid;

  @override
  _MouthCaptureState createState() => _MouthCaptureState();
}

class _MouthCaptureState extends State<MouthCapture> {
  CameraController _controller;
  XFile _imgFile;

  bool _hasCaptured = false, _uploading = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();

    final frontCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
    );
    _controller = CameraController(
      frontCamera ?? cameras.last,
      ResolutionPreset.max,
      enableAudio: false,
    );
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void _onCameraFlip() async {
    if (_controller != null) {
      await _controller.dispose();
    }
    CameraLensDirection newLensDirection =
        _controller.description.lensDirection == CameraLensDirection.front
            ? CameraLensDirection.back
            : CameraLensDirection.front;

    final cameraDescription = cameras.firstWhere(
      (cam) => cam.lensDirection == newLensDirection,
    );

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
    );
    _controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        print("Camera Error!");
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _capturePhoto() async {
    if (mounted)
      setState(() {
        _hasCaptured = false;
      });

    try {
      _imgFile = await _controller.takePicture();

      if (_imgFile == null) {
        return;
      }
      if (mounted)
        setState(() {
          _hasCaptured = true;
        });
    } catch (ex) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          "Image Capture Failed!",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  _recapturePhoto() {
    if (mounted)
      setState(() {
        _hasCaptured = false;
      });
  }

  _uploadPhoto(BuildContext context) async {
    try {
      setState(() {
        _uploading = true;
      });
      final uploadTask = storage
          .ref()
          .child('mouth_images/${_imgFile.name}')
          .putFile(File(_imgFile.path));

      final uploadTaskSnapshot = await uploadTask;

      final fileURL = await uploadTaskSnapshot.ref.getDownloadURL();

      await db
          .collection(DATA_COLLECTION)
          .doc(widget.entryUid)
          .update({'mouthImageURL': fileURL});

      Navigator.of(context)
          .pushNamedAndRemoveUntil(
        ThankYou.id,
        (_) => false,
      )
          .then((_) {
        if (mounted)
          setState(() {
            _hasCaptured = false;
          });
      });
    } catch (ex) {
      setState(() {
        _hasCaptured = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Data Upload Failed!",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Center(
            child: Text('No Camera Found!'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Data Droplet"),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _hasCaptured
                  ? SizedBox()
                  : SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: CameraPreview(_controller),
                    ),
              _hasCaptured
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 3,
                            ),
                          ),
                          child: Image.file(File(_imgFile.path)),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15),
                      ],
                    )
                  : SizedBox(),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.55,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          width: 5,
                          color: _hasCaptured
                              ? Colors.transparent
                              : Colors.red.shade900,
                        )),
                  ),
                  !_hasCaptured
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: _capturePhoto,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 20),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(75),
                                  border: Border.all(
                                    width: 5,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Take Photo",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.lightBlue,
                              ),
                              child: IconButton(
                                onPressed: _onCameraFlip,
                                iconSize: 40,
                                color: Colors.white,
                                icon: Icon(Icons.flip_camera_ios_outlined),
                              ),
                            ),
                          ],
                        )
                      : (!_uploading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: _recapturePhoto,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    width: 75,
                                    height: 75,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(75),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.replay,
                                          color: Colors.white,
                                          size: 27,
                                        ),
                                        Text(
                                          "Retake",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _uploadPhoto(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 30),
                                    width: 75,
                                    height: 75,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(75),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.upload_file,
                                          color: Colors.white,
                                          size: 27,
                                        ),
                                        Text(
                                          "Upload",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              margin: EdgeInsets.only(bottom: 30),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Uploading",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
