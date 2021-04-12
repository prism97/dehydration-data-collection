import 'package:flutter/material.dart';

import 'face_record.dart';

class FaceDemo extends StatelessWidget {
  static final String id = 'mouth_demo';
  final String entryUid;

  const FaceDemo({Key key, @required this.entryUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('App Name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Container(
                color: Colors.grey,
                width: 200,
                height: 200,
              ),
              Text('Demo Video here'),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => FaceCapture(
                        entryUid: entryUid,
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
