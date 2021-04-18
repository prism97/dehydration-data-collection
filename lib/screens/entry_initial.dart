import 'package:data_collection_app/providers/data_id_provider.dart';
import 'package:provider/provider.dart';

import '../constants/maps.dart';
import '../constants/values.dart';
import 'entry_additional.dart';
import '../widgets/base_button.dart';
import '../widgets/base_form_field.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EntryInitial extends StatefulWidget {
  static final String id = 'entry_initial';

  @override
  _EntryInitialState createState() => _EntryInitialState();
}

class _EntryInitialState extends State<EntryInitial> {
  bool _moisturizedCheck = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  String _docId;

  int _hoursOfSleep, _activityLevel = 1;
  double _currentWeight;

  Future<bool> _insertData(bool isHydrated) async {
    if (_formKey.currentState.validate() && _moisturizedCheck) {
      final prevDocId =
          Provider.of<DataIdProvider>(context, listen: false).dataId;
      final entryData = {
        'hoursOfSleep': _hoursOfSleep,
        'activityLevel': _activityLevel,
        'currentWeight': _currentWeight,
        'isHydrated': isHydrated,
        'uid': auth.currentUser.uid,
      };
      try {
        if (prevDocId == null || prevDocId.isEmpty) {
          final tempDocRef =
              await db.collection(DATA_COLLECTION).add(entryData);
          _docId = tempDocRef.id;
        } else {
          await db.collection(DATA_COLLECTION).doc(prevDocId).set(entryData);
          _docId = prevDocId;
        }
        return true;
      } catch (ex) {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              ex?.message ?? ex?.toString() ?? "Data Entry Failed!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          "Please provide valid data!",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('Data Droplet'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 50),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BaseFormField(
                  label:
                      'How many hours of sleep have you had within last 24 hours?',
                  formField: TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (val) => (val == null || val.isEmpty)
                        ? 'This field is required'
                        : null,
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
                        title: Text(
                          option.key,
                          style: TextStyle(fontSize: 16),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _activityLevel = val;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                Divider(
                  height: 2,
                  thickness: 2,
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CheckboxListTile(
                    dense: true,
                    value: _moisturizedCheck,
                    title: Text(
                      'I have not applied any moisturizer to my face in the last 6 hours',
                      style: TextStyle(fontSize: 16),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _moisturizedCheck = val;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Are you hydrated now?',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: BaseButton(
                        text: 'Yes',
                        onPressed: () async {
                          if (await _insertData(true)) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EntryAdditional(
                                  hydrated: true,
                                  entryUid: _docId,
                                ),
                              ),
                            );
                          }
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
                        onPressed: () async {
                          if (await _insertData(false)) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EntryAdditional(
                                  hydrated: false,
                                  entryUid: _docId,
                                ),
                              ),
                            );
                          }
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
