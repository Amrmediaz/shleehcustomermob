import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shleehcustomer/core/network/urls.dart';
import 'package:shleehcustomer/core/strings/assets_path.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/booking/domain/entities/booking_details_model.dart';
import 'package:shleehcustomer/features/booking/presentation/pages/chalet_booking_date_page.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/chalet_detail_page/price_Widgets/list_price_widget.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/chalet_detail_page/price_Widgets/price_widget.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../booking/presentation/pages/booking_detail_page.dart';
import '../../../../chalets/presentation/bloc/chalets/chalets_bloc.dart';
import '../../../../chalets/presentation/pages/chalet_detail_page.dart';
import '../../../../home_page/presentation/bloc/home/home_bloc.dart';
import 'data_widget/price_widget.dart';


class BookingDetailWidget extends StatelessWidget {
  final BookingDetails bookingDetails;

  BookingDetailWidget({
    Key? key,
    required this.bookingDetails,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
        child:Column(children: [
          Text(getTextByKey(key: TranslationKey.keyBookingDetails),style: TextStyles.textStyleTitle(context).copyWith(color: primaryColor),),
          Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DEFAULT_CORNER),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              BookingDataWidget(
                title: getTextByKey(key: TranslationKey.keyBookingDate),
                data: bookingDetails.crreatedDate.split('T')[0],
              ),
              const Divider(),
              BookingDataWidget(
                title: getTextByKey(key: TranslationKey.keyBookingTime),
                data: bookingDetails.crreatedDate.split('T')[1].split('.')[0],
              ),
              const Divider(),
              BookingDataWidget(
                title: getTextByKey(key: TranslationKey.keyDays),
                data: "${bookingDetails.bookingDays.length}",
              ),

              const Divider(),
              BookingDataWidget(
                title: getTextByKey(key: TranslationKey.keyBookingPrice),
                data: "${bookingDetails.paidAmount} ${getTextByKey(key: TranslationKey.keyOMR)}",
              ),
              const Divider(),
        Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(DEFAULT_CORNER),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTextByKey(key: TranslationKey.keyBookingDate),
                  style: TextStyles.textStyleHeadline(context, titleSizeFactor: 0.60).copyWith(color: primaryColor),
                ),
                const Divider(),
                Column(
                  children: bookingDetails.bookingDays.map((day) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            day.day,
                            style: TextStyles.textStyleBody(context).copyWith(color: Colors.black),
                          ),
                          Text(
                            day.isFullDay ? getTextByKey(key: TranslationKey.keyFullDay) : getTextByKey(key: TranslationKey.keyHalfDay),
                            style: TextStyles.textStyleBody(context).copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

    ) ,
            ActionBtn(onPressed: (){  BlocProvider.of<ChaletsBloc>(context)
                .add(LoadChaletsById(id: "${bookingDetails.buildingID}"));
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const ChaletDetailPage(),
              withNavBar: false,
            );}, btnTitle: getTextByKey(key: TranslationKey.keyDisplayChalet), btnColor: primaryColor)
            ]))],)
    );
  }
}



class FrameBtn extends StatefulWidget {
  final String title;
  final bool isClicked;
  FrameBtn({required this.title, required this.isClicked});
  @override
  State<FrameBtn> createState() => _FrameBtnState();
}

class _FrameBtnState extends State<FrameBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
          color: widget.isClicked ? primaryColor : GreyColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(DEFAULT_CORNER))),
      child: Text(widget.title,
          style: widget.isClicked
              ? TextStyles.textStyleButton(context, scaleFactor: 0.6)
              : TextStyles.textStyleHelper(context, scaleFactor: 0.7)
                  .copyWith(color: Colors.grey.shade500)),
    );
  }
}
