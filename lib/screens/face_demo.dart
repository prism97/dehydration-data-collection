import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'face_record.dart';

class FaceDemo extends StatefulWidget {
  static final String id = 'face_demo';
  final String entryUid;
  final bool hydrated;

  const FaceDemo({Key key, @required this.entryUid, @required this.hydrated})
      : super(key: key);

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Face Video Record',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Demo Video',
                ),
                SizedBox(
                  height: 10,
                ),
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
                  '• Keep your face within the bounding box\n\n• You can switch between front & back camera using the camera flip button\n\n• Record your bare face for 5 seconds\n\n• A preview will be shown, you can choose to retake the video or upload immediately',
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
                          hydrated: widget.hydrated,
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
      ),
    );
  }
}
