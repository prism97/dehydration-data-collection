import 'package:flutter/material.dart';

class BaseButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  const BaseButton({Key key, @required this.text, @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      child: Text(text),
      onPressed: onPressed,
    );
  }
}
