import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../constants/values.dart';
import '../main.dart' show cameras;
import 'mouth_demo.dart';

class FaceCapture extends StatefulWidget {
  FaceCapture({Key key, this.entryUid, this.hydrated}) : super(key: key);

  final String entryUid;
  final bool hydrated;

  @override
  _FaceCaptureState createState() => _FaceCaptureState();
}

class _FaceCaptureState extends State<FaceCapture> with WidgetsBindingObserver {
  CameraController _controller;
  VideoPlayerController _vidPlayercontroller;
  XFile _vidFile;
  final _progressStreamController = StreamController<double>.broadcast();
  double _progress = 0.0;
  bool _recordingStarted = false;
  bool _hasCaptured = false;
  bool _playingPreview = false;

  // --------------------- NOTE: FaceDetector Disabled ---------------------
  // List<Face> faces;
  // bool _detected = true;
  // bool _imageStreamStarted = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  // final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector();

  @override
  void initState() {
    super.initState();

    final frontCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
    );
    _controller = CameraController(
      frontCamera ?? cameras.last,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      if (mounted) setState(() {});
    });
  }

  // void _detectFaceFromImageStream(BuildContext context) {
  //   final double scale = MediaQuery.of(context).devicePixelRatio;
  //   // bounding box dimensions
  //   final double left =
  //       scale * (MediaQuery.of(context).size.width * (0.25 / 2));
  //   final double top = scale * 50;
  //   final double right =
  //       scale * MediaQuery.of(context).size.width * (0.75 + (0.25 / 2));
  //   final double bottom =
  //       scale * (50 + MediaQuery.of(context).size.height * 0.55);

  //   ImageRotation rotation =
  //       rotationIntToImageRotation(_controller.description.sensorOrientation);

  //   _imageStreamStarted = true;
  //   _controller.startImageStream((image) {
  //     if (!_detected) {
  //       detect(image, _faceDetector.processImage, rotation).then((value) {
  //         faces = value;
  //         if (faces.length != 1) return;
  //         print('face detected');
  //         Face detectedFace = faces[0];
  //         final box = detectedFace.boundingBox;
  //         // TODO : check left condition
  //         if (box.left < left &&
  //             box.top > top &&
  //             box.right < right &&
  //             box.bottom < bottom) {
  //           print(detectedFace.boundingBox);
  //           print('left : $left, top : $top, right : $right, bottom : $bottom');

  //           setState(() {
  //             _detected = true;
  //           });
  //         }
  //       });
  //     }
  //   });
  // }

  @override
  void dispose() {
    _controller?.dispose();
    _progressStreamController?.close();
    super.dispose();
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

  void _captureVideo() async {
    if (mounted)
      setState(() {
        _hasCaptured = false;
      });
    _progress = 0.0;

    try {
      _controller.startVideoRecording();
      while (_progress < 1.0) {
        await Future.delayed(Duration(milliseconds: 50), () {
          _progress += 0.005;
          _progressStreamController.add(_progress);
        });
      }

      await Future.delayed(Duration(milliseconds: 100), () {
        _progressStreamController.add(100.0);
      });
      if (mounted)
        setState(() {
          _hasCaptured = true;
        });

      _vidFile = await _controller.stopVideoRecording();

      if (_vidFile == null) {
        return;
      }
      if (mounted)
        setState(() {
          _hasCaptured = true;
        });

      _vidPlayercontroller = VideoPlayerController.file(File(_vidFile.path));

      _vidPlayercontroller.addListener(() {
        if (mounted) setState(() {});
      });
      _vidPlayercontroller.setLooping(true);
      _vidPlayercontroller.initialize().then((_) {
        if (mounted) setState(() {});
      });
    } catch (ex) {
      _progressStreamController.add(-1.0);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          "Video Capture Failed!",
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

  _recaptureVideo() {
    _progressStreamController.add(-1.0);
    _progress = 0.0;
    if (mounted)
      setState(() {
        _hasCaptured = false;
      });
  }

  _uploadVideo(BuildContext context) async {
    try {
      _progressStreamController.add(200);
      final uploadTask = storage
          .ref()
          .child('face_videos/${_vidFile.name}')
          .putFile(File(_vidFile.path));

      final uploadTaskSnapshot = await uploadTask;

      final fileURL = await uploadTaskSnapshot.ref.getDownloadURL();

      await db
          .collection(DATA_COLLECTION)
          .doc(widget.entryUid)
          .update({'faceVideoURL': fileURL});

      _progressStreamController.add(1);

      await _addEntryToSharedPreferences();

      await Future.delayed(Duration(milliseconds: 500));

      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => MouthDemo(
            entryUid: widget.entryUid,
          ),
        ),
      )
          .then((_) {
        _progressStreamController.add(-1.0);
        _progress = 0.0;
        if (mounted)
          setState(() {
            _hasCaptured = false;
          });
      });
    } catch (ex) {
      _progressStreamController.add(-1.0);
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

  void _playPreview() {
    if (mounted && !_playingPreview) {
      setState(() {
        _playingPreview = true;
      });
      _vidPlayercontroller.play();
    }
  }

  void _pausePreview() {
    if (mounted && _playingPreview) {
      _vidPlayercontroller.pause();
      setState(() {
        _playingPreview = false;
      });
    }
  }

  Future<void> _addEntryToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String currentUserId = FirebaseAuth.instance.currentUser.uid;

    await sharedPreferences.setString(
        currentUserId + "_timestamp", DateTime.now().toIso8601String());

    String str = widget.hydrated
        ? (currentUserId + "_hydrated")
        : (currentUserId + "_dehydrated");

    int count = sharedPreferences.get(str) ?? 0;
    sharedPreferences.setInt(str, count + 1);
  }

  @override
  Widget build(BuildContext context) {
    // if (_controller.value.isInitialized && !_imageStreamStarted) {
    //   _detectFaceFromImageStream(context);
    // }

    // if (_controller.value.isInitialized && _detected && !_recordingStarted) {
    //   _controller.stopImageStream().then((value) {
    //     _recordingStarted = true;
    //     _captureVideo();
    //   });
    // }

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
                          child: VideoPlayer(_vidPlayercontroller),
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
                  StreamBuilder<double>(
                    stream: _progressStreamController.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == -1.0) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: _captureVideo,
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
                        );
                      } else if (snapshot.hasData && !snapshot.hasError) {
                        if (snapshot.data == 100.0) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: _recaptureVideo,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 30),
                                  width: 75,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(75),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                onTap: _playingPreview
                                    ? _pausePreview
                                    : _playPreview,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 30),
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _playingPreview
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_filled_outlined,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      Text(
                                        _playingPreview ? "Pause" : "Preview",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _uploadVideo(context);
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                          );
                        } else if (snapshot.data == 200.0) {
                          return Container(
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
                          );
                        } else if (snapshot.data >= 1.0) {
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
