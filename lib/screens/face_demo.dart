import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'face_record.dart';

class FaceDemo extends StatefulWidget {
  static final String id = 'face_demo';
  final String entryUid;

  const FaceDemo({Key key, @required this.entryUid}) : super(key: key);

  @override
  _FaceDemoState createState() => _FaceDemoState();
}

class _FaceDemoState extends State<FaceDemo> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/face_demo.mp4');

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('Data Droplet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.grey,
                width: 200,
                height: 300,
                child: VideoPlayer(_controller),
              ),
              SizedBox(height: 10),
              Text(
                'Instructions',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '• Keep your entire face within the bounding box',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(
                height: 10,
              ),
              TextButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all<double>(8),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FaceCapture(
                        entryUid: widget.entryUid,
                      ),
                    ),
                  );
                },
                child: Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
