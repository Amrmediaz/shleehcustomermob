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
import '../../../../../core/util/cashed_data/cashed_file.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/app_bar_back.dart';
import '../../bloc/chalets/chalets_bloc.dart';

class FilterWidget extends StatefulWidget {
  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

List<String> governorates = ["Dohfar"];
List<String> states = [
  "Salalalh",
  "Mirbat",
  "Sadah",
  "Shalim",
  "Thumrait",
  "Maqusht",
  "Dalkut",
  "Rakhyut",
  "AL mazyona",
  "Taqah"
];
List<String> services = [
  'menPool',
  'womenPool',
  'grill',
  'volleyBall',
  'animals',
  'childPool',
  'football',
  "games",
  "childGames"
];

class _FilterWidgetState extends State<FilterWidget> {
  String? selectedGovernorate;
  String? selectedState;
  RangeValues selectedPriceRange = const RangeValues(20, 200);
  Map<String, bool> selectedServices = {
    'menPool': true,
    'womenPool': false,
    'grill': false,
    'volleyBall': false,
    'animals': false,
    'childPool': false,
    'football': false,
    'games': false,
    'childGames': false,
  };
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkDeviceType();
  }
  var deviceType = "Phone";
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
                getTextByKey(key: TranslationKey.keyLocation),
                style: TextStyles.textStyleTitle(context),
              ),
               SizedBox(height: CasheFile.isTablet ? 20 : 10),
              _buildContainer(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: Text(
                        getTextByKey(key: TranslationKey.keySelectGovernorate),
                        style: TextStyles.textStyleBody(context)),
                    value: selectedGovernorate,
                    onChanged: (newValue) {
                      setState(() {
                        selectedGovernorate = newValue;
                      });
                    },
                    icon: const Icon(
                        Icons.arrow_drop_down), // Adding dropdown arrow icon
                    items: governorates
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          getTextByKey(key: value),
                          style: TextStyles.textStyleBody(context),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
               SizedBox(height: CasheFile.isTablet ? 26 : 16),
              _buildContainer(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: Text(getTextByKey(key: TranslationKey.keySelectState),
                        style: TextStyles.textStyleBody(context)),

                    value: selectedState,
                    onChanged: (newValue) {
                      setState(() {
                        selectedState = newValue;
                      });
                    },
                    icon: const Icon(
                        Icons.arrow_drop_down), // Adding dropdown arrow icon
                    items: states.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          getTextByKey(key: value),
                          style: TextStyles.textStyleBody(context),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
               SizedBox(height: CasheFile.isTablet ? 44 : 24),
              Text(
                getTextByKey(key: TranslationKey.keySelectPriceRange),
                style: TextStyles.textStyleTitle(context),
              ),
              RangeSlider(
                activeColor: yellowAppColor,
                values: selectedPriceRange,
                min: 0,
                max: 700,
                divisions: 40,
                labels: RangeLabels(
                  selectedPriceRange.start.round().toString(),
                  selectedPriceRange.end.round().toString(),
                ),
                onChanged: (RangeValues newRange) {
                  setState(() {
                    selectedPriceRange = newRange;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("10 ${getTextByKey(key: TranslationKey.keyOMR)}",
                      style: TextStyles.textStyleTitle(context,
                              titleSizeFactor: 0.5)
                          .copyWith(color: Colors.grey.shade600)),
                  Text("700 ${getTextByKey(key: TranslationKey.keyOMR)}",
                      style: TextStyles.textStyleTitle(context,
                              titleSizeFactor: 0.5)
                          .copyWith(color: Colors.grey.shade600))
                ],
              ),
               SizedBox(height: CasheFile.isTablet ? 44 : 24),
              Text(
                getTextByKey(key: TranslationKey.keySelectServices),
                style: TextStyles.textStyleTitle(context),
              ),
               SizedBox(height: CasheFile.isTablet ? 15 : 5),
              GridView.count(
                childAspectRatio: 3,
                crossAxisCount:
                CasheFile.isTablet ? 3 : 2 , // Change this value to adjust the number of columns
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: services.map((String service) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedServices[service] = !selectedServices[service]!;
                      });
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: CasheFile.isTablet ? 50 : 30, // Adjust height as needed
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedServices[service] ?? false
                              ? primaryColor
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(CasheFile.isTablet ? 20 : 8),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        margin:  EdgeInsets.all(CasheFile.isTablet ? 8.0 : 4.0) ,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/chalets/${service.toLowerCase().replaceAll(' ', '_')}.svg',
                              width:  CasheFile.isTablet ? 56 : 36.0,
                              height:CasheFile.isTablet ? 56 : 36.0,
                            ),
                             SizedBox(width :CasheFile.isTablet ? 8.0 : 4.0),
                            Flexible(
                              child: Text(getTextByKey(key: service),
                                  style: TextStyles.textStyleHelper(context)
                                      .copyWith(
                                    color: selectedServices[service] ?? false
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ActionBtn(
                onPressed: () {
                  BlocProvider.of<ChaletsBloc>(context).add(GetAllChaletsEvent(
                      pageNumber: CommonFunctions.pageNumberChalets,
                      body: {
                        "page": 1,
                        "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
                        "serviesList": selectedServices.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList(),
                        "fromPrice": selectedPriceRange.start.toInt(),
                        "toPrice": selectedPriceRange.end.toInt(),
                        "state": selectedState,
                        "governorate": selectedGovernorate
                      }));
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: ChaletsByFilterPage(filterBody: {
                      "serviesList": selectedServices.entries
                          .where((e) => e.value)
                          .map((e) => e.key)
                          .toList(),
                      "fromPrice": selectedPriceRange.start.toInt(),
                      "toPrice":  selectedPriceRange.end.toInt(),
                      "state": selectedState,
                      "governorate": selectedGovernorate
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
  void checkDeviceType()async{
    CommonFunctions().checkDeviceType(context).then((value) {

        deviceType = value;
        setState(() {

        });

    });
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
