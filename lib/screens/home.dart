import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/data_id_provider.dart';
import '../widgets/base_button.dart';
import 'entry_initial.dart';
import 'log_in.dart';

class Home extends StatelessWidget {
  static final String id = 'home';
  final auth = FirebaseAuth.instance;

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
                Text(
                  '• Before iftar',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '• Before going to sleep at night',
                  style: TextStyle(fontSize: 16),
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
                        : Text(
                            'Less than 4 hours have passed since your last entry. Please wait a while before providing the next entry!');
                  }
                  return Container();
                }),
            FutureBuilder<int>(
                future: _getCurrentStepFromLocalStorage(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _currentStep = snapshot.data;
                    return Container(
                      width: MediaQuery.of(context).size.width - 100,
                      height: 200,
                      child: Theme(
                        data: ThemeData(
                          canvasColor: Theme.of(context).primaryColorLight,
                          shadowColor: Colors.transparent,
                        ),
                        child: Stepper(
                          type: StepperType.horizontal,
                          physics: NeverScrollableScrollPhysics(),
                          controlsBuilder: (BuildContext context,
                              {onStepContinue, onStepCancel}) {
                            return Text(
                              'You have ${5 - _currentStep} more entries to go!',
                              textAlign: TextAlign.center,
                            );
                          },
                          steps: [
                            _buildStep(_currentStep, 1),
                            _buildStep(_currentStep, 2),
                            _buildStep(_currentStep, 3),
                            _buildStep(_currentStep, 4),
                            _buildStep(_currentStep, 5),
                          ],
                          currentStep: _currentStep,
                        ),
                      ),
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

  Step _buildStep(int currentStep, int stepIndex) {
    return Step(
      title: Text(''),
      content: Text(''),
      isActive: currentStep >= 0,
      state: currentStep >= stepIndex ? StepState.complete : StepState.disabled,
    );
  }
}
