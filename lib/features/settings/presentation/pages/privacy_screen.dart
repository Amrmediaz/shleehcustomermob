import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/Constants.dart';
import '../../../../core/widgets/app_bar_back.dart';
import '../widgets/settings_widget/privacy_widget.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body:SafeArea(
        child:_buildBody(context)));
  }

  Widget _buildBody(BuildContext context) {
    return ListView(padding: PADDING_PAGE, children: [
      AppBarBack(leadingWidgetAction: () {
        Navigator.pop(context);
      }),
      const PrivacyWidget(
      )
    ]);
  }
}
