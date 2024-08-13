import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalets_by_filter_page.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/styles/text/text_style.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/app_bar_back.dart';
import '../../bloc/chalets/chalets_bloc.dart';

class FilterDateWidget extends StatefulWidget {
  @override
  _FilterDateWidgetState createState() => _FilterDateWidgetState();
}



class _FilterDateWidgetState extends State<FilterDateWidget> {
  List<DateTime?> dates = [];
  DateTime currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              AppBarBack(
                leadingWidgetAction: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
              Text(
                getTextByKey(key: TranslationKey.keyCheckDateAvailability),
                style: TextStyles.textStyleTitle(context),
              ),
              CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                    todayTextStyle: TextStyles.textStyleBody(context),
                    calendarType: CalendarDatePicker2Type.range,
                    firstDate: currentDate.add(const Duration(days: 1)),
                    lastDate: currentDate
                        .add(const Duration(days: 1))
                        .add(const Duration(days: 3 * 30)),
                    selectableDayPredicate: (value) {
                      if (formatDate(value) == formatDate(DateTime.now())) {
                        return false;
                      } else {
                        return true;
                      }
                    },
                  ),
                  value: dates,
                  onValueChanged: (datesValue) {
                    dates = datesValue;

                  }),
              const SizedBox(height: 16),
              ActionBtn(
                onPressed: () {
                 CommonFunctions.pageNumberFilterChalets = 1;
                  BlocProvider.of<ChaletsBloc>(context).add(GetAllChaletsEvent(
                      pageNumber: CommonFunctions.pageNumberChalets,
                      body: {
                        "page": 1,
                        "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
                        "startDate": "${dates[0]!}".replaceAll(" ", "T"),
                        "endDate": "${dates[1]!}".replaceAll(" ", "T"),

                      }));
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: ChaletsByFilterPage(filterBody: {
                      "startDate": "${dates[0]!}".replaceAll(" ", "T"),
                      "endDate": "${dates[1]!}".replaceAll(" ", "T"),
                    }),
                    withNavBar: false,
                  );
                },
                btnTitle: getTextByKey(key: TranslationKey.keyApplyFilters),
                btnColor: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(8.0),
      child: child,
    );
  }
}
