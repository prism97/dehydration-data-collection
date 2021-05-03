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
    'At noon',
    'Before iftaar',
    'Before going to sleep at night',
  ];

  final steps = [
    'Provide some basic information about your current condition',
    'Record your face for 5 seconds',
    'Take a picture of your mouth, keeping it open',
  ];

  // returns true if a new entry can be taken
  Future<bool> _checkMinimumTimeInterval() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String currentUserId = FirebaseAuth.instance.currentUser.uid;

    if (sharedPreferences.containsKey(currentUserId)) {
      String timestampString =
          sharedPreferences.getStringList(currentUserId).last;
      DateTime lastEntryTime = DateTime.parse(timestampString);
      if (DateTime.now().difference(lastEntryTime).inHours >= 4) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<int> _getCurrentStepFromLocalStorage() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String currentUserId = FirebaseAuth.instance.currentUser.uid;

    if (sharedPreferences.containsKey(currentUserId)) {
      int currentStep = 0;
      List<String> timestampStrings =
          sharedPreferences.getStringList(currentUserId);

      String currentDay = timestampStrings.first;
      int currentDayEntryCount = 0;
      timestampStrings.forEach((str) {
        if (currentDay.substring(0, 10).compareTo(str.substring(0, 10)) == 0) {
          currentDayEntryCount++;
        } else {
          if (currentDayEntryCount >= 2) currentStep++;
          currentDayEntryCount = 1;
          currentDay = str;
        }
      });
      if (currentDayEntryCount >= 2) currentStep++;
      return (currentStep > 5) ? 5 : currentStep;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    int _currentStep;

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
                  height: 8,
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
                            vertical: MediaQuery.of(context).size.height / 3,
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
                    return snapshot.data
                        ? BaseButton(
                            text: 'PROVIDE NEW DATA',
                            onPressed: () {
                              Provider.of<DataIdProvider>(context,
                                      listen: false)
                                  .dataId = "";
                              Navigator.of(context)
                                  .pushReplacementNamed(EntryInitial.id);
                            },
                          )
                        : Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey.shade700,
                                size: 30,
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  'Less than 4 hours have passed since your last entry. Please wait a while before providing the next entry!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade800,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              )
                            ],
                          );
                  }
                  return Container();
                }),
            FutureBuilder<int>(
                future: _getCurrentStepFromLocalStorage(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _currentStep = snapshot.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // (5 - _currentStep) > 0
                          //     ? 'You have ${5 - _currentStep} more entries to go!'
                          //     : ' ',
                          // TODO: fetch from shared resources
                          'Entries in hydrated state : 0\nEntries in dehydrated state : 0',
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
                          'Please provide at least one entry in hydrated state and at least two entries in dehydrated state.',
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
            'Preferred times for data entry during Ramadan',
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
