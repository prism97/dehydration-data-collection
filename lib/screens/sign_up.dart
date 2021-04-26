import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/maps.dart';
import '../constants/values.dart';
import '../widgets/base_button.dart';
import '../widgets/base_form_field.dart';
import 'log_in.dart';

class SignUp extends StatefulWidget {
  static final String id = 'sign_up';

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _loading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _dobController = TextEditingController();

  String _email, _password;
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

    if (_signUpFormKey.currentState.validate()) {
      final auth = FirebaseAuth.instance;
      final db = FirebaseFirestore.instance;

      try {
        final userCreds = await auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        final deviceInfo = DeviceInfoPlugin();
        Map<String, String> device = {};
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          device = {
            'brand': androidInfo.brand,
            'model': androidInfo.model,
            'industrialDesign': androidInfo.device,
          };
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          device = {
            'brand': 'Apple',
            'model': iosInfo.model,
            'industrialDesign': iosInfo.utsname.machine,
          };
        }

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
          },
          'deviceInfo': device
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
        title: Text('Data Droplet'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Form(
              key: _signUpFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        validator: (val) => EmailValidator.validate(val)
                            ? null
                            : 'Invalid e-mail address',
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
                        validator: (val) =>
                            val == null ? 'This field is required' : null,
                        onChanged: (val) {
                          setState(() {
                            _sex = val;
                          });
                        },
                      ),
                    ),
                    BaseFormField(
                      label: 'Date of Birth',
                      formField: TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'This field is required'
                            : null,
                        onTap: () async {
                          final dob = await showDatePicker(
                            context: context,
                            initialDate: DateTime(1990),
                            firstDate: DateTime(1901),
                            lastDate: DateTime.now(),
                          );

                          setState(() {
                            _dateOfBirth = dob;
                            _dobController.text = dob
                                .toLocal()
                                .toString()
                                .split(" ")[0]
                                .replaceAll("-", "/");
                          });
                        },
                      ),
                    ),
                    BaseFormField(
                      label: 'Password',
                      formField: TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'This field is required'
                            : null,
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
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'This field is required'
                            : (val.compareTo(_password) == 0
                                ? null
                                : 'Passwords don\'t match'),
                      ),
                    ),
                    BaseFormField(
                      label: 'Enter your tentative weight (in kilograms)',
                      formField: TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'This field is required'
                            : null,
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
