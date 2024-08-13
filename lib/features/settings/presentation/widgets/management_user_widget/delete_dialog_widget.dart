import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/styles/text/text_style.dart';
import '../../bloc/setting/setting_bloc.dart';

class DeleteDialog extends StatelessWidget {
  final dynamic userId;
  const DeleteDialog({super.key , required this.userId});

  @override
  Widget build(BuildContext context) {
    return   Column(
      children: [
        Text(
          getTextByKey(
              key: TranslationKey
                  .keyAreYouSureMakeTodeleteTheAccount),
          style: TextStyles.textStyleTitle(
              context),
        ),
        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            ElevatedButton(
                style: ElevatedButton
                    .styleFrom(
                    backgroundColor:
                    primaryColor),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  getTextByKey(
                      key: TranslationKey
                          .keyNo),
                  style: TextStyles
                      .textStyleBody(
                      context)
                      .copyWith(
                      color:
                      Colors.white),
                )),
            const SizedBox(
              width: 50,
            ),
            ElevatedButton(
                style: ElevatedButton
                    .styleFrom(
                    backgroundColor:
                    Colors.grey
                        .shade500),
                onPressed: () {
                  BlocProvider.of<
                      SettingBloc>(
                      context)
                      .add(DeleteUserEvent(userId));
                },
                child: Text(
                  getTextByKey(
                      key: TranslationKey
                          .keyDeleteAccount),
                  style: TextStyles
                      .textStyleBody(
                      context)
                      .copyWith(
                      color:
                      Colors.white),
                )),
          ],
        )
      ],
    );
  }
}
