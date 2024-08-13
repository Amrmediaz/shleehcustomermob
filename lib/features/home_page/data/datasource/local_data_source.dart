import 'package:dartz/dartz.dart';
import 'package:shleehcustomer/core/error/failures.dart';
import 'package:shleehcustomer/features/home_page/data/model/onboard_model.dart';

import '../../../landing/domain/entities/onboard.dart';

abstract class OnboardLocalDataSource {
  List<OnboardModel> getOnBoardItems();
}
class OnboardLocalDataSourceImp implements OnboardLocalDataSource{
  @override
 List<OnboardModel> getOnBoardItems()  {
    var firstOnBoard =  OnboardModel(title: "المقدمة", description: "مرحبا بكم في التطبيق الرسمي لملاحظات بلدية ظفار! شارك اقتراحاتك القيمة وقدم الشكاوى بسلاسة مع هذا التطبيق سهل الاستخدام. تمكين السكان من المساهمة بنشاط في تعزيز مجتمعنا، مدخلاتك مهمة. قم بالإبلاغ عن المشكلات واقتراح الأفكار والتفاعل مع بلديتك من أجل جعل ظفار أكثر حيوية. قم بالتنزيل الآن لتكون جزءًا من التغيير الإيجابي!", imageUrl: "https://www.adpushup.com/blog/wp-content/uploads/2022/01/undraw_Accept_terms_re_lj38-770x515.png");
    var secondOnBoard =  OnboardModel(title: "الأقتراحات", description: "ساهم في تقدم بلدية ظفار دون عناء من خلال ميزة عملية الاقتراحات لدينا! شارك أفكارك المبتكرة وملاحظاتك القيمة مباشرة من خلال التطبيق. اقتراحاتك مهمة، لأننا نسعى جاهدين لبناء مجتمع سريع الاستجابة يلبي احتياجاتك. أرسل وتتبع وشارك في تشكيل مستقبل ظفار. معًا، دعونا نحدث فرقًا!", imageUrl: "https://site.surveysparrow.com/wp-content/uploads/2020/12/anonymous-suggestion-box_1.png");
    var thirdOnBoard =  OnboardModel(title: "الشكاوي", description: "قم بالإبلاغ عن المشكلات وحلها بكفاءة من خلال عملية تقديم الشكاوى في تطبيق بلدية ظفار. استمتع بتجربة طريقة سلسة للتعبير عن مخاوفك، بدءًا من الحفر ووصولاً إلى الخدمات العامة. تتيح لك واجهتنا سهلة الاستخدام إرسال الشكاوى وإرفاق الصور وتتبع التقدم دون عناء. تعليقاتك مهمة للغاية لجعل ظفار أفضل. قم بالتنزيل الآن لتكون مشاركًا استباقيًا في تحسين المجتمع - لأن كل شكوى هي فرصة للتغيير الإيجابي!", imageUrl: "https://media.product.which.co.uk/prod/images/original/gm-3b879fff-169d-4dd6-b90a-03913c30188f-24-complain-ombudsman.jpg");
    var onBoardList = [firstOnBoard,secondOnBoard,thirdOnBoard];
    return onBoardList;

  }

}