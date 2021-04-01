import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:data_collection_app/constants/values.dart';
import 'package:flutter/material.dart';

import '../main.dart' show cameras;
import './mouth_record.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FaceCapture extends StatefulWidget {
  static const String id = "face_capture";

  FaceCapture({Key key, this.entryUid}) : super(key: key);

  final String entryUid;

  @override
  _FaceCaptureState createState() => _FaceCaptureState();
}

class _FaceCaptureState extends State<FaceCapture> {
  CameraController _controller;
  final _progressStreamController = StreamController<double>();
  double _progress = 0.0;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _progressStreamController?.close();
    super.dispose();
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller.dispose();
    }
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
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

  _captureVideo() async {
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
          .child('videos/${vidFile.name}')
          .putFile(File(vidFile.path));

      await Future.delayed(Duration(milliseconds: 100), () {
        _progressStreamController.add(100.0);
      });

      final uploadTaskSnapshot = await uploadTask;

      final fileURL = await uploadTaskSnapshot.ref.getDownloadURL();

      await db
          .collection(DATA_COLLECTION)
          .doc(widget.entryUid)
          .update({'faceVideoURL': fileURL});

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MouthCapture(
            entryUid: widget.entryUid,
          ),
        ),
      );
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
        title: Text("App Name"),
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
