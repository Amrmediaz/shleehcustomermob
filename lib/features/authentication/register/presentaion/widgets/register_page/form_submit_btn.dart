import 'package:flutter/material.dart';

class FormRegisterBtn extends StatelessWidget {
  final void Function() onPressed;


  const FormRegisterBtn({
    Key? key,
    required this.onPressed,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        child: Text("Register"),);
  }
}
