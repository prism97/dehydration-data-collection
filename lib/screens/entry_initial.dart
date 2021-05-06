import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_collection_app/screens/face_demo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/maps.dart';
import '../constants/values.dart';
import '../providers/data_id_provider.dart';
import '../widgets/base_button.dart';
import '../widgets/base_form_field.dart';

class EntryInitial extends StatefulWidget {
  static final String id = 'entry_initial';

  @override
  _EntryInitialState createState() => _EntryInitialState();
}

class _EntryInitialState extends State<EntryInitial> {
  bool _loading = false;
  bool _moisturizedCheck = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  String _docId;

  int _hoursOfSleep, _activityLevel = 1;
  double _currentWeight;
  bool _hydrated;
  int _glassCount;
  TimeOfDay _lastFluidIntakeTime;
  int _todayOrYesterday = 0;
  TextEditingController _controller = TextEditingController();

  Future<bool> _insertData(bool isHydrated) async {
    if (_formKey.currentState.validate() && _moisturizedCheck) {
      setState(() {
        _loading = true;
      });
      final prevDocId =
          Provider.of<DataIdProvider>(context, listen: false).dataId;
      final entryData = {
        'hoursOfSleep': _hoursOfSleep,
        'activityLevel': _activityLevel,
        'currentWeight': _currentWeight,
        'isHydrated': isHydrated,
        'createdAt': DateTime.now().toIso8601String(),
        'uid': auth.currentUser.uid,
      };
      if (isHydrated) {
        entryData['glassCount'] = _glassCount;
      } else {
        entryData['lastFluidIntakeTime'] = _lastFluidIntakeTime.format(context);

        int hour = _lastFluidIntakeTime.hour;
        int minute = _lastFluidIntakeTime.minute;
        DateTime temp;
        if (_todayOrYesterday == 0) {
          temp = DateTime.now();
        } else {
          temp = DateTime.now().subtract(Duration(days: 1));
        }
        DateTime fluidIntakeDateTime =
            DateTime(temp.year, temp.month, temp.day, hour, minute);
        int hours = DateTime.now().difference(fluidIntakeDateTime).inHours;
        entryData['hoursAfterLastFluidIntake'] = hours;
      }
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
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return 'This field is required!';
                      final hrs = int.tryParse(val);
                      if (hrs == null || hrs < 0 || hrs > 24)
                        return 'Invalid data!';
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        _hoursOfSleep = int.tryParse(val);
                      });
                    },
                  ),
                ),
                BaseFormField(
                  label:
                      'What is your weight (in kilograms) right now? [optional]',
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
                    subtitle: Text(
                      '* Required condition',
                      style: TextStyle(color: Colors.red),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _moisturizedCheck = val;
                      });
                    },
                  ),
                ),
                _hydrated != null
                    ? Container()
                    : Padding(
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
                _hydrated != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: BaseButton(
                          text:
                              _hydrated ? 'Hydrated Entry' : 'Dehydrated Entry',
                          color: Colors.purple.shade300,
                          onPressed: () {},
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: BaseButton(
                              text: 'Yes',
                              onPressed: () {
                                setState(() {
                                  _hydrated = true;
                                });
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
                                setState(() {
                                  _hydrated = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                _hydrated == null
                    ? Container()
                    : _hydrated
                        ? BaseFormField(
                            label:
                                'How many glasses of fluid did you take in the last 4 hours?',
                            formField: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'This field is required'
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  _glassCount = int.tryParse(val);
                                });
                              },
                            ),
                          )
                        : BaseFormField(
                            label: 'Last time of fluid intake',
                            formField: Column(
                              children: [
                                DropdownButtonFormField(
                                  value: _todayOrYesterday,
                                  items: [
                                    DropdownMenuItem<int>(
                                        value: 0, child: Text('Today')),
                                    DropdownMenuItem<int>(
                                        value: 1, child: Text('Yesterday')),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _todayOrYesterday = val;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  readOnly: true,
                                  controller: _controller,
                                  validator: (val) =>
                                      (_controller.text == null ||
                                              _controller.text.isEmpty)
                                          ? 'This field is required'
                                          : null,
                                  onTap: () async {
                                    _lastFluidIntakeTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    _controller.text =
                                        _lastFluidIntakeTime.format(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                _hydrated == null
                    ? Container()
                    : _loading
                        ? LinearProgressIndicator()
                        : BaseButton(
                            text: 'NEXT',
                            onPressed: () async {
                              setState(() {
                                _loading = true;
                              });
                              if (await _insertData(_hydrated)) {
                                setState(() {
                                  _loading = false;
                                });
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => FaceDemo(
                                      entryUid: _docId,
                                      hydrated: _hydrated,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
