import 'package:data_collection_app/constants/maps.dart';
import 'package:data_collection_app/screens/home.dart';
import 'package:data_collection_app/widgets/base_button.dart';
import 'package:data_collection_app/widgets/base_form_field.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  static final String id = 'sign_up';

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String _email, _password, _confirmPassword;
  int _sex;
  DateTime _dateOfBirth;
  double _weight;
  // diseases
  bool _malnutrition = false,
      _heartDisease = false,
      _kidneyDisease = false,
      _diabetes = false,
      _skinDisease = false,
      _sleepDisorder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('App Name'),
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BaseFormField(
                  label: 'E-mail',
                  formField: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) {
                      setState(() {
                        _email = val;
                      });
                    },
                  ),
                ),
                BaseFormField(
                  label: 'Sex',
                  formField: DropdownButtonFormField<int>(
                    value: _sex,
                    items: sexOptions.entries.map((option) {
                      return DropdownMenuItem<int>(
                        value: option.value,
                        child: Text(option.key),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _sex = val;
                      });
                    },
                  ),
                ),
                BaseFormField(
                  label: 'Date of birth',
                  formField: InputDatePickerFormField(
                    fieldLabelText: '',
                    fieldHintText: 'mm/dd/yyyy',
                    firstDate: DateTime(1920),
                    lastDate: DateTime.now(),
                    onDateSaved: (newDate) {
                      setState(() {
                        _dateOfBirth = newDate;
                      });
                    },
                  ),
                ),
                BaseFormField(
                  label: 'Password',
                  formField: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    onChanged: (val) {
                      setState(() {
                        _password = val;
                      });
                    },
                  ),
                ),
                BaseFormField(
                  label: 'Confirm Password',
                  formField: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    onChanged: (val) {
                      setState(() {
                        _confirmPassword = val;
                      });
                    },
                  ),
                ),
                BaseFormField(
                  label: 'Enter your tentative weight (in kilograms)',
                  formField: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(() {
                        _weight = double.parse(val);
                      });
                    },
                  ),
                ),
                _buildDiseaseCheckboxes(),
                BaseButton(
                  text: 'Sign Up',
                  onPressed: () {
                    //TODO: form validation (later)
                    //TODO: create user with email-password
                    //TODO: add new user document to firestore users collection
                    Navigator.of(context).pushReplacementNamed(Home.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BaseFormField _buildDiseaseCheckboxes() {
    return BaseFormField(
      label:
          'Do you have any of the following diseases?\nCheck the ones that apply',
      formField: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          children: [
            CheckboxListTile(
              dense: true,
              value: _malnutrition,
              title: Text('Malnutrition'),
              subtitle: Text('e.g. vitamin/iron deficiency'),
              onChanged: (val) {
                setState(() {
                  _malnutrition = val;
                });
              },
            ),
            CheckboxListTile(
              dense: true,
              value: _heartDisease,
              title: Text('Heart Diseases'),
              onChanged: (val) {
                setState(() {
                  _heartDisease = val;
                });
              },
            ),
            CheckboxListTile(
              dense: true,
              value: _kidneyDisease,
              title: Text('Kidney Diseases'),
              onChanged: (val) {
                setState(() {
                  _kidneyDisease = val;
                });
              },
            ),
            CheckboxListTile(
              dense: true,
              value: _diabetes,
              title: Text('Diabetes'),
              onChanged: (val) {
                setState(() {
                  _diabetes = val;
                });
              },
            ),
            CheckboxListTile(
              dense: true,
              value: _skinDisease,
              title: Text('Skin Diseases'),
              onChanged: (val) {
                setState(() {
                  _skinDisease = val;
                });
              },
            ),
            CheckboxListTile(
              dense: true,
              value: _sleepDisorder,
              title: Text('Sleep Disorder'),
              onChanged: (val) {
                setState(() {
                  _sleepDisorder = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
