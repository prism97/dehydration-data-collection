import 'package:data_collection_app/constants/maps.dart';
import 'package:data_collection_app/screens/log_in.dart';
import 'package:data_collection_app/widgets/base_button.dart';
import 'package:data_collection_app/widgets/base_form_field.dart';
import 'package:data_collection_app/constants/values.dart';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  static final String id = 'sign_up';

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _loading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _signUpFormKey = GlobalKey<FormState>();

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

  _registerUser() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    //TODO: form validation (later)
    if (_signUpFormKey.currentState.validate()) {
      if (_password != _confirmPassword) {
        setState(() {
          _loading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            "Confirm password does not match with Password!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ));
      }

      final auth = FirebaseAuth.instance;
      final db = FirebaseFirestore.instance;

      try {
        final userCreds = await auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        await db.collection(USERS_COLLECTION).doc(userCreds.user.uid).set({
          'email': _email,
          'sex': _sex,
          'dateOfBirth': Timestamp.fromDate(_dateOfBirth),
          'weight': _weight,
          'diseases': {
            'malnutrition': _malnutrition,
            'heartDisease': _heartDisease,
            'kidneyDisease': _kidneyDisease,
            'diabetes': _diabetes,
            'skinDisease': _skinDisease,
            'sleepDisorder': _sleepDisorder,
          }
        });

        setState(() {
          _loading = false;
        });

        Navigator.of(context).pushNamedAndRemoveUntil(
          LogIn.id,
          (route) => false,
        );
      } catch (ex) {
        setState(() {
          _loading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            ex?.message ?? ex?.toString() ?? "SignUp failed! Try again!",
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
          "Please provide valid input!",
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('App Name'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Form(
              key: _signUpFormKey,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10),
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
                      label: 'Date of Birth',
                      formField: InputDatePickerFormField(
                        fieldLabelText: '',
                        fieldHintText: 'mm/dd/yyyy',
                        firstDate: DateTime(1920),
                        lastDate: DateTime.now(),
                        onDateSubmitted: (newDate) {
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
                    _loading
                        ? SizedBox(
                            width: 50,
                            child: LinearProgressIndicator(),
                          )
                        : BaseButton(
                            text: 'Sign Up',
                            onPressed: _registerUser,
                          ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 5),
                        InkWell(
                          onTap: () =>
                              Navigator.of(context).pushNamedAndRemoveUntil(
                            LogIn.id,
                            (route) => false,
                          ),
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BaseFormField _buildDiseaseCheckboxes() {
    return BaseFormField(
      label:
          'Do you have any of the following diseases?\nPlease check the ones that apply.',
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
              title: Text(
                'Malnutrition',
                style: TextStyle(fontSize: 16),
              ),
              subtitle: Text(
                'e.g. vitamin/iron deficiency',
                style: TextStyle(fontSize: 14),
              ),
              onChanged: (val) {
                setState(() {
                  _malnutrition = val;
                });
              },
            ),
            CheckboxListTile(
              dense: true,
              value: _heartDisease,
              title: Text(
                'Heart Diseases',
                style: TextStyle(fontSize: 16),
              ),
              onChanged: (val) {
                setState(() {
                  _heartDisease = val;
                });
              },
            ),
            CheckboxListTile(
              dense: true,
              value: _kidneyDisease,
              title: Text(
                'Kidney Diseases',
                style: TextStyle(fontSize: 16),
              ),
              onChanged: (val) {
                setState(() {
                  _kidneyDisease = val;
                });
              },
            ),
            CheckboxListTile(
              dense: true,
              value: _diabetes,
              title: Text(
                'Diabetes',
                style: TextStyle(fontSize: 16),
              ),
              onChanged: (val) {
                setState(() {
                  _diabetes = val;
                });
              },
            ),
            CheckboxListTile(
              dense: true,
              value: _skinDisease,
              title: Text(
                'Skin Diseases',
                style: TextStyle(fontSize: 16),
              ),
              onChanged: (val) {
                setState(() {
                  _skinDisease = val;
                });
              },
            ),
            CheckboxListTile(
              dense: true,
              value: _sleepDisorder,
              title: Text(
                'Sleep Disorder',
                style: TextStyle(fontSize: 16),
              ),
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
