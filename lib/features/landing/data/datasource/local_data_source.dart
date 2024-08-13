import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/core/error/failures.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/features/landing/data/model/onboard_model.dart';

abstract class OnboardLocalDataSource {
  List<OnboardModel> getOnBoardItems();
}
class OnboardLocalDataSourceImp implements OnboardLocalDataSource{
  @override
 List<OnboardModel> getOnBoardItems()  {
    var firstOnBoard =  OnboardModel(title: getTextByKey(key:TranslationKey.keyOnBoardFirstTitle), description: getTextByKey(key:TranslationKey.keyOnBoardFirstDescription), imageUrl: "assets/images/landing/map_landing.png");
    var secondOnBoard =  OnboardModel(title:  getTextByKey(key:TranslationKey.keyOnBoardSecondTitle), description: getTextByKey(key:TranslationKey.keyOnBoardSecondDescription), imageUrl: "assets/images/landing/calendar_landing.png");
    var thirdOnBoard =  OnboardModel(title: getTextByKey(key:TranslationKey.keyOnBoardThirdTitle), description: getTextByKey(key:TranslationKey.keyOnBoardThirdDescription), imageUrl: "assets/images/landing/payment_landing.png");
    var onBoardList = [firstOnBoard,secondOnBoard,thirdOnBoard];
    return onBoardList;

  }

}