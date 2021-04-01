import 'package:data_collection_app/constants/maps.dart';
import 'package:data_collection_app/widgets/base_button.dart';
import 'package:data_collection_app/widgets/base_form_field.dart';
import 'package:flutter/material.dart';

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
  int _appearanceLevel, _tearLevel, _skinPinchLevel, _respirationLevel;
  int _glassCount;

  @override
  Widget build(BuildContext context) {
    String str = widget.hydrated ? 'Hydrated' : 'Dehydrated';
    return Scaffold(
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
                            'How many glasses of fluid did you take recently?',
                        formField: TextFormField(
                          keyboardType: TextInputType.number,
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
                          keyboardType: TextInputType.number,
                        ),
                      ),
                BaseButton(
                  text: 'Submit',
                  onPressed: () {
                    //TODO: add info to entry in firestore
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
