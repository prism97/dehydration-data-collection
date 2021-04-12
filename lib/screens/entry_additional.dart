import 'package:data_collection_app/constants/maps.dart';
import 'package:data_collection_app/constants/values.dart';
import 'package:data_collection_app/screens/face_demo.dart';
import 'package:data_collection_app/widgets/base_button.dart';
import 'package:data_collection_app/widgets/base_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EntryAdditional extends StatefulWidget {
  static final String id = 'entry_additional';
  final bool hydrated;
  final String entryUid;

  const EntryAdditional(
      {Key key, @required this.hydrated, @required this.entryUid})
      : super(key: key);

  @override
  _EntryAdditionalState createState() => _EntryAdditionalState();
}

class _EntryAdditionalState extends State<EntryAdditional> {
  bool _loading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  int _appearanceLevel = 0,
      _tearLevel = 0,
      _skinPinchLevel = 0,
      _respirationLevel = 0;
  int _glassCount;
  TimeOfDay _lastFluidIntakeTime;
  TextEditingController _controller = TextEditingController();

  _insertData() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _loading = true;
      });

      try {
        Map<String, dynamic> entry = {
          'appearanceLevel': _appearanceLevel,
          'tearLevel': _tearLevel,
          'skinPinchLevel': _skinPinchLevel,
          'respirationLevel': _respirationLevel,
        };
        if (widget.hydrated) {
          entry['glassCount'] = _glassCount;
        } else {
          entry['lastFluidIntakeTime'] = _lastFluidIntakeTime.format(context);
        }
        await db.collection(DATA_COLLECTION).doc(widget.entryUid).update(entry);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => FaceDemo(
              entryUid: widget.entryUid,
            ),
          ),
        );
      } catch (ex) {
        setState(() {
          _loading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            ex?.message ?? ex?.toString() ?? "Data Entry Failed!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      setState(() {
        _loading = false;
      });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    String str = widget.hydrated ? 'Hydrated' : 'Dehydrated';
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('App Name'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$str entry',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Please enter the following information based on  your personal observations',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                BaseFormField(
                  label: 'General Appearance',
                  formField: Column(
                    children: appearanceOptions.entries.map((option) {
                      return RadioListTile(
                        dense: true,
                        groupValue: _appearanceLevel,
                        value: option.value,
                        title: Text(option.key),
                        onChanged: (val) {
                          setState(() {
                            _appearanceLevel = val;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                BaseFormField(
                  label: 'Tears',
                  formField: Column(
                    children: tearOptions.entries.map((option) {
                      return RadioListTile(
                        dense: true,
                        groupValue: _tearLevel,
                        value: option.value,
                        title: Text(option.key),
                        onChanged: (val) {
                          setState(() {
                            _tearLevel = val;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                BaseFormField(
                  label: 'Skin Pinch',
                  formField: Column(
                    children: skinPinchOptions.entries.map((option) {
                      return RadioListTile(
                        dense: true,
                        groupValue: _skinPinchLevel,
                        value: option.value,
                        title: Text(option.key),
                        onChanged: (val) {
                          setState(() {
                            _skinPinchLevel = val;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                BaseFormField(
                  label: 'Respirations',
                  formField: Column(
                    children: respirationOptions.entries.map((option) {
                      return RadioListTile(
                        dense: true,
                        groupValue: _respirationLevel,
                        value: option.value,
                        title: Text(option.key),
                        onChanged: (val) {
                          setState(() {
                            _respirationLevel = val;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                widget.hydrated
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
                              _glassCount = int.parse(val);
                            });
                          },
                        ),
                      )
                    : BaseFormField(
                        label: 'Last time of fluid intake',
                        formField: TextFormField(
                          readOnly: true,
                          controller: _controller,
                          validator: (val) => (_controller.text == null ||
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
                      ),
                BaseButton(
                  text: 'Submit',
                  onPressed: () async {
                    await _insertData();
                  },
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
