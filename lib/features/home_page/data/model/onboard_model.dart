import 'package:shleehcustomer/features/home_page/domain/entities/onboard.dart';
import 'package:equatable/equatable.dart';

import '../../../landing/domain/entities/onboard.dart';

class OnboardModel extends Onboard {
   OnboardModel({ required String title, required String description , required String imageUrl})
      : super( title: title, description: description,imageUrl: imageUrl);

}