import 'package:flutter/material.dart';

void showErrSnack({required BuildContext context, required String text}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
    duration: Duration(seconds: 5),
    backgroundColor: Color.fromARGB(193, 246, 55, 42),
    action: SnackBarAction(
      label: 'X',
      textColor: Colors.white,
      onPressed: () {},
    ),
  ));
}

void showSuccSnack({required BuildContext context, required String text}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(text),
    duration: Duration(seconds: 5),
    backgroundColor: Colors.teal,
    action: SnackBarAction(
      label: 'X',
      textColor: Colors.white,
      onPressed: () {},
    ),
  ));
}
