import 'package:data_collection_app/screens/home.dart';
import 'package:flutter/material.dart';

class ThankYou extends StatelessWidget {
  static final String id = 'thank_you';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('Data Droplet'),
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: Colors.purple.shade300,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Your data was uploaded successfully. Thank you so much for taking the time to provide your valuable data!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(Home.id);
            },
            child: Text(
              'RETURN TO HOME',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
