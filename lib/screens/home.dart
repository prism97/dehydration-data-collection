import 'package:data_collection_app/providers/data_id_provider.dart';
import 'package:data_collection_app/screens/entry_initial.dart';
import 'package:data_collection_app/screens/log_in.dart';
import 'package:data_collection_app/widgets/base_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  static final String id = 'home';
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // TODO: fetch from database/local storage (later)
    int _currentStep = 2;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('App Name'),
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
            BaseButton(
              text: 'PROVIDE NEW DATA',
              onPressed: () {
                Provider.of<DataIdProvider>(context, listen: false).dataId = "";
                Navigator.of(context).pushReplacementNamed(EntryInitial.id);
              },
            ),
            Container(
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
            ),
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
