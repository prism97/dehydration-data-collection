import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/data_id_provider.dart';
import '../widgets/base_button.dart';
import 'entry_initial.dart';
import 'log_in.dart';

class Home extends StatelessWidget {
  static final String id = 'home';
  final auth = FirebaseAuth.instance;

  final preferredTimes = [
    'Before going to sleep at night',
    'Right after waking up in the morning'
  ];

  final steps = [
    'Provide some basic information about your current condition',
    'Record your face for 5 seconds',
    'Take a picture of your mouth, keeping it open (optional)',
  ];

  // returns true if a new entry can be taken
  Future<bool> _checkMinimumTimeInterval() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String currentUserId = FirebaseAuth.instance.currentUser.uid;

    String key = currentUserId + "_timestamp";
    if (sharedPreferences.containsKey(key)) {
      String timestampString = sharedPreferences.getString(key);
      DateTime lastEntryTime = DateTime.parse(timestampString);
      if (DateTime.now().difference(lastEntryTime).inHours >= 6) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<Map<String, int>> _getEntryCountFromLocalStorage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String currentUserId = FirebaseAuth.instance.currentUser.uid;

    int hydrated = sharedPreferences.getInt(currentUserId + "_hydrated") ?? 0;
    int dehydrated =
        sharedPreferences.getInt(currentUserId + "_dehydrated") ?? 0;
    return {
      "hydrated": hydrated,
      "dehydrated": dehydrated,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('Data Droplet'),
        leading: null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                auth.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  LogIn.id,
                  (route) => false,
                );
              } catch (ex) {
                print(ex);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  auth?.currentUser?.email ?? " ",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                _buildPreferredTimesBox(),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 12),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    foregroundColor: MaterialStateProperty.all(Colors.blue),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  onPressed: () {
                    showGeneralDialog(
                      barrierDismissible: true,
                      barrierLabel: 'Close',
                      context: context,
                      pageBuilder: (context, a, b) {
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: MediaQuery.of(context).size.height / 4,
                          ),
                          child: _buildSteps(),
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'VIEW STEPS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            FutureBuilder<bool>(
                future: _checkMinimumTimeInterval(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return BaseButton(
                      text: 'PROVIDE NEW DATA',
                      onPressed: () {
                        if (snapshot.data) {
                          Provider.of<DataIdProvider>(context, listen: false)
                              .dataId = "";
                          Navigator.of(context)
                              .pushReplacementNamed(EntryInitial.id);
                        } else {
                          showGeneralDialog(
                            barrierDismissible: true,
                            barrierLabel: 'Close',
                            context: context,
                            pageBuilder: (context, a, b) {
                              return Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical:
                                      MediaQuery.of(context).size.height / 3,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.purple.shade300,
                                        size: 40,
                                      ),
                                      SizedBox(height: 16),
                                      Expanded(
                                        child: Text(
                                          'Less than 6 hours have passed since your last entry. Please wait a while before providing the next entry!',
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      BaseButton(
                                        text: 'OK',
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    );
                  }
                  return Container();
                }),
            FutureBuilder<Map<String, int>>(
                future: _getEntryCountFromLocalStorage(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    int hydrated = snapshot.data['hydrated'];
                    int dehydrated = snapshot.data['dehydrated'];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entries in hydrated state : $hydrated\nEntries in dehydrated state : $dehydrated',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Please provide at least one entry in hydrated state and one entry in dehydrated state.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 32,
                        ),
                      ],
                    );
                  }
                  return Container(
                    width: 0,
                    height: 0,
                  );
                }),
          ],
        ),
      ),
    );
  }

  Container _buildPreferredTimesBox() {
    return Container(
      width: Size.infinite.width,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blueAccent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferred times for data entry',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Wrap(
            spacing: 10,
            children: preferredTimes
                .map(
                  (time) => Chip(
                    backgroundColor: Colors.blueAccent,
                    label: Text(
                      time,
                      style: TextStyle(
                        // fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSteps() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      itemBuilder: (context, index) {
        return Row(
          children: [
            Container(
              height: 32,
              width: 32,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (index + 1).toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: Text(
                steps[index],
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 32,
          child: Align(
            alignment: Alignment.centerLeft,
            child: VerticalDivider(
              color: Colors.blue,
              thickness: 5,
              width: 32,
              indent: 5,
              endIndent: 5,
            ),
          ),
        );
      },
      itemCount: steps.length,
    );
  }
}
