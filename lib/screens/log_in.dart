import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/base_button.dart';
import '../widgets/base_form_field.dart';
import 'home.dart';
import 'sign_up.dart';

class LogIn extends StatefulWidget {
  static final String id = 'log_in';

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool _loading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _logInFormKey = GlobalKey<FormState>();

  String _email, _password;

  _logInUser() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    if (_logInFormKey.currentState.validate() &&
        _email != null &&
        _password != null) {
      final auth = FirebaseAuth.instance;

      try {
        await auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        Navigator.of(context).pushNamedAndRemoveUntil(
          Home.id,
          (Route<dynamic> route) => false,
        );

        setState(() {
          _loading = false;
        });
      } catch (ex) {
        setState(() {
          _loading = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            ex.message ?? ex.toString() ?? "SignUp failed! Try again!",
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
      body: SingleChildScrollView(
        child: Form(
          key: _logInFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 50),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: MediaQuery.of(context).size.height / 3,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Enter your e-mail address'),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      fillColor:
                                          Theme.of(context).primaryColorLight,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (val) =>
                                        EmailValidator.validate(val)
                                            ? null
                                            : 'Invalid e-mail address',
                                    onChanged: (val) {
                                      setState(() {
                                        _email = val;
                                      });
                                    },
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await FirebaseAuth.instance
                                          .sendPasswordResetEmail(
                                              email: _email);
                                      setState(() {
                                        _email = null;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Reset Password'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _loading
                    ? LinearProgressIndicator()
                    : BaseButton(
                        text: 'Log In',
                        onPressed: _logInUser,
                      ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(width: 5),
                    InkWell(
                      onTap: () =>
                          Navigator.of(context).pushNamedAndRemoveUntil(
                        SignUp.id,
                        (route) => false,
                      ),
                      child: Text(
                        "Sign Up",
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
    );
  }
}
