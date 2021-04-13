import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../constants/values.dart';
import '../main.dart' show cameras;
import '../utils.dart';
import 'home.dart';

class MouthCapture extends StatefulWidget {
  MouthCapture({Key key, @required this.entryUid}) : super(key: key);

  final String entryUid;

  @override
  _MouthCaptureState createState() => _MouthCaptureState();
}

class _MouthCaptureState extends State<MouthCapture> {
  CameraController _controller;
  final _progressStreamController = StreamController<double>();
  double _progress = 0.0;
  List<Face> faces;
  bool _detected = false,
      _recordingStarted = false,
      _imageStreamStarted = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector(
    FaceDetectorOptions(enableLandmarks: true),
  );

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

  void _detectFaceFromImageStream(BuildContext context) {
    final double scale = MediaQuery.of(context).devicePixelRatio;
    // bounding box dimensions
    final double left =
        scale * (MediaQuery.of(context).size.width * (0.25 / 2));
    final double top = scale * 50;
    final double right =
        scale * MediaQuery.of(context).size.width * (0.75 + (0.25 / 2));
    final double bottom =
        scale * (50 + MediaQuery.of(context).size.height * 0.55);

    ImageRotation rotation =
        rotationIntToImageRotation(_controller.description.sensorOrientation);

    _imageStreamStarted = true;
    _controller.startImageStream((image) {
      if (!_detected) {
        detect(image, _faceDetector.processImage, rotation).then((value) {
          faces = value;
          if (faces.length != 1) return;
          print('face detected');
          Face detectedFace = faces[0];

          FaceLandmark noseBase =
              detectedFace.getLandmark(FaceLandmarkType.noseBase);
          FaceLandmark leftMouth =
              detectedFace.getLandmark(FaceLandmarkType.leftMouth);
          FaceLandmark rightMouth =
              detectedFace.getLandmark(FaceLandmarkType.rightMouth);
          FaceLandmark bottomMouth =
              detectedFace.getLandmark(FaceLandmarkType.bottomMouth);
          if (bottomMouth == null || leftMouth == null || rightMouth == null) {
            return;
          } else {
            print('mouth detected');
          }

          double openMouthGap = bottomMouth.position.dy - noseBase.position.dy;
          if (leftMouth.position.dx > left &&
              rightMouth.position.dx < right &&
              bottomMouth.position.dy < bottom &&
              openMouthGap > 200) {
            // print('left : $left, top : $top, right : $right, bottom : $bottom');
            // print(noseBase.position.dy);
            // print(bottomMouth.position.dy);

            setState(() {
              _detected = true;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _progressStreamController?.close();
    super.dispose();
  }

  void _captureVideo() async {
    _controller.startVideoRecording();
    while (_progress < 1.0) {
      await Future.delayed(Duration(milliseconds: 50), () {
        _progress += 0.005;
        _progressStreamController.add(_progress);
      });
    }

    try {
      final vidFile = await _controller.stopVideoRecording();

      final uploadTask = storage
          .ref()
          .child('mouth_videos/${vidFile.name}')
          .putFile(File(vidFile.path));

      await Future.delayed(Duration(milliseconds: 100), () {
        _progressStreamController.add(100.0);
      });

      final uploadTaskSnapshot = await uploadTask;

      final fileURL = await uploadTaskSnapshot.ref.getDownloadURL();

      await db
          .collection(DATA_COLLECTION)
          .doc(widget.entryUid)
          .update({'mouthVideoURL': fileURL});

      Navigator.of(context).pushReplacementNamed(Home.id);
    } catch (ex) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
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
    if (_controller.value.isInitialized && !_imageStreamStarted) {
      _detectFaceFromImageStream(context);
    }

    if (_controller.value.isInitialized && _detected && !_recordingStarted) {
      _controller.stopImageStream().then((value) {
        _recordingStarted = true;
        _captureVideo();
      });
    }

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
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: CameraPreview(_controller),
              ),
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
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                  StreamBuilder<double>(
                    stream: _progressStreamController.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return InkWell(
                          onTap: _detected ? _captureVideo : () {},
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20),
                            width: 75,
                            height: 75,
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
                                "Start",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.hasData && !snapshot.hasError) {
                        if (snapshot.data == 100.0) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 20),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(75),
                            ),
                            child: Center(
                              child: Text(
                                "Uploading",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }
                        if (snapshot.data >= 1.0) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 20),
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(75),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: snapshot.data,
                              strokeWidth: 10,
                            ),
                          ),
                        );
                      }
                      return SizedBox();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
