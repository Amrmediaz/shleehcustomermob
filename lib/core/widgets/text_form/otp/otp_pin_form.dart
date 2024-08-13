import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../strings/language.dart';
import '../../../styles/text/text_style.dart';
import '../text_form_field_widget.dart';
import 'otp_item_text.dart';
typedef PinSubmitCallback = void Function(String pin);

class PinForm extends StatefulWidget {
  final PinSubmitCallback onSubmit;

  PinForm({required this.onSubmit});
  @override
  _PinFormState createState() => _PinFormState();

}

class _PinFormState extends State<PinForm> {
  final TextEditingController _pin1Controller = TextEditingController();
  final TextEditingController _pin2Controller = TextEditingController();
  final TextEditingController _pin3Controller = TextEditingController();
  final TextEditingController _pin4Controller = TextEditingController();
  final FocusNode _pin1Focus = FocusNode();
  final FocusNode _pin2Focus = FocusNode();
  final FocusNode _pin3Focus = FocusNode();
  final FocusNode _pin4Focus = FocusNode();
 @override
  void initState() {
    super.initState();
    _pin1Focus.requestFocus();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [


        const SizedBox(height: 15),
        Row( mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormFieldWidget(controller:_pin1Controller, multiLines: false, name: '*' ,),
            const SizedBox(width: 30),
            TextFormFieldWidget(controller:_pin2Controller, multiLines: false, name: '*' ,),
            const SizedBox(width: 30),
            TextFormFieldWidget(controller:_pin3Controller, multiLines: false, name: '*' ,),
            const SizedBox(width: 30),
            TextFormFieldWidget(controller:_pin4Controller, multiLines: false, name: '*' ,),

          ],
        ),

      ],
    );
  }
}

