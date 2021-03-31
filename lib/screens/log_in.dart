import 'package:data_collection_app/widgets/base_button.dart';
import 'package:data_collection_app/widgets/base_form_field.dart';
import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  static final String id = 'log_in';

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String _email, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('App Name'),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              BaseButton(
                text: 'Log In',
                onPressed: () {
                  //TODO: form validation (later)
                  //TODO: sign user in with email-password
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
