import 'package:flutter/material.dart';

import 'home.dart';
import 'mouth_record.dart';

class MouthDemo extends StatelessWidget {
  static final String id = 'mouth_demo';
  final String entryUid;

  const MouthDemo({Key key, @required this.entryUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('App Name'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(Home.id);
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
                height: 200,
              ),
              Text('Demo Video here'),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MouthCapture(
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
