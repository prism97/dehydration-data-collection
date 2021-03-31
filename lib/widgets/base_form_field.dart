import 'package:flutter/material.dart';

class BaseFormField extends StatelessWidget {
  final String label;
  final Widget formField;

  const BaseFormField({
    Key key,
    @required this.label,
    @required this.formField,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 8,
        ),
        formField,
        SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
