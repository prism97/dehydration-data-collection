import 'package:flutter/material.dart';

class BaseFormField extends StatelessWidget {
  final String label;
  final TextInputType keyboardType;

  const BaseFormField({
    Key key,
    @required this.label,
    @required this.keyboardType,
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
        TextFormField(
          keyboardType: keyboardType,
          obscureText: keyboardType == TextInputType.visiblePassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
