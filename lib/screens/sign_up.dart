import 'package:data_collection_app/widgets/base_form_field.dart';
import 'package:flutter/material.dart';

class SignUp extends StatelessWidget {
  static final String id = 'sign_up';

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
            children: [
              BaseFormField(
                label: 'E-mail',
                keyboardType: TextInputType.emailAddress,
              ),
              BaseFormField(
                label: 'Password',
                keyboardType: TextInputType.visiblePassword,
              ),
              BaseFormField(
                label: 'Confirm Password',
                keyboardType: TextInputType.visiblePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
