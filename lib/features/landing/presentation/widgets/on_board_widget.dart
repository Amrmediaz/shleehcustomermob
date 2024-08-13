import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/features/landing/domain/entities/onboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/loading_image.dart';

class OnBoardWidget {
  final String title;
  final String description;
  final String image;
  OnBoardWidget({
    required this.title,
    required this.description,
    required this.image,
  });
}

class OnboardItemWidget extends StatelessWidget {
  final Onboard onboardItem;
  OnboardItemWidget({required this.onboardItem});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child:SingleChildScrollView(child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            onboardItem.title,
            style: TextStyles.textStyleHeadline(context).copyWith(color: Colors.black),
          ),
          const SizedBox(height: 3.0),
          Text(
            onboardItem.description,
            textAlign: TextAlign.center,
            style:  TextStyles.textStyleBody(context).copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 3.0),

          ImageLoadingWidget(imageUrl: onboardItem.imageUrl,),


        ],
      ),
    ));
  }
}