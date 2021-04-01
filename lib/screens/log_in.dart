import 'package:data_collection_app/screens/sign_up.dart';
import 'package:data_collection_app/widgets/base_button.dart';
import 'package:data_collection_app/widgets/base_form_field.dart';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

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
    //TODO: form validation (later)
    if (_logInFormKey.currentState.validate() &&
        _email != null &&
        _password != null) {
      final auth = FirebaseAuth.instance;

      try {
        await auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // TODO: Navigate to HomePage
        // Navigator.of(context)
        //       .pushNamedAndRemoveUntil('home', (Route<dynamic> route) => false);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            "Logged In!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ));

        setState(() {
          _loading = false;
        });

        // Navigator.of(context).pushNamedAndRemoveUntil(
        //   LogIn.id,
        //   (route) => false,
        // );
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
        title: Text('App Name'),
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
                    onChanged: (val) {
                      setState(() {
                        _password = val;
                      });
                    },
                  ),
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
