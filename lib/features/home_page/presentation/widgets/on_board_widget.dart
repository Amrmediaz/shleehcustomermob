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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageLoadingWidget(imageUrl: onboardItem.imageUrl,),
          SizedBox(height: 20.0),
          Text(
            onboardItem.title,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.0),
          Text(
            onboardItem.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}