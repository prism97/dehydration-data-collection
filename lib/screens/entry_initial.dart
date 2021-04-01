import 'package:data_collection_app/constants/maps.dart';
import 'package:data_collection_app/screens/entry_additional.dart';
import 'package:data_collection_app/widgets/base_button.dart';
import 'package:data_collection_app/widgets/base_form_field.dart';
import 'package:flutter/material.dart';

class EntryInitial extends StatefulWidget {
  static final String id = 'entry_initial';

  @override
  _EntryInitialState createState() => _EntryInitialState();
}

class _EntryInitialState extends State<EntryInitial> {
  int _hoursOfSleep, _activityLevel;
  double _currentWeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('App Name'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BaseFormField(
                  label: 'How many hours of sleep have you had today?',
                  formField: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(() {
                        _hoursOfSleep = int.parse(val);
                      });
                    },
                  ),
                ),
                BaseFormField(
                  label: 'What is your weight now? (in kilograms)',
                  formField: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(() {
                        _currentWeight = double.parse(val);
                      });
                    },
                  ),
                ),
                BaseFormField(
                  label: 'How active would you say you were today?',
                  formField: Column(
                    children: activityOptions.entries.map((option) {
                      return RadioListTile(
                        dense: true,
                        groupValue: _activityLevel,
                        value: option.value,
                        title: Text(option.key),
                        onChanged: (val) {
                          setState(() {
                            _activityLevel = val;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Are you hydrated now?',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: BaseButton(
                        text: 'Yes',
                        onPressed: () {
                          //TODO: create new entry in firestore
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => EntryAdditional(
                                hydrated: true,
                                entryUid: 'hydrated', //TODO: from firestore
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: BaseButton(
                        text: 'No',
                        color: Colors.redAccent.shade100,
                        onPressed: () {
                          //TODO: create new entry in firestore
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => EntryAdditional(
                                hydrated: false,
                                entryUid: 'dehydrated', //TODO: from firestore
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
