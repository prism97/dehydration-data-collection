import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'home.dart';
import 'mouth_record.dart';

class MouthDemo extends StatefulWidget {
  static final String id = 'mouth_demo';
  final String entryUid;

  const MouthDemo({Key key, @required this.entryUid}) : super(key: key);

  @override
  _MouthDemoState createState() => _MouthDemoState();
}

class _MouthDemoState extends State<MouthDemo> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/mouth_demo.mp4');

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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                Home.id,
                (_) => false,
              );
            },
            child: Text(
              'Skip >>',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
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
                '• Keep your lips within the bounding box\n• Open your mouth wide\n• Zoom in as much as possible',
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
                      builder: (context) => MouthCapture(
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
