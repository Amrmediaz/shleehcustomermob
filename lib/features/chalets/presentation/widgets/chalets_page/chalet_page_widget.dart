import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalet_filter_page.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalets_map_screen.dart';

import '../../../../../core/strings/assets_path.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/app_bar_back.dart';
import '../../../../../core/widgets/text_icon.dart';
import '../../../domain/entities/chalet.dart';
import 'chalet_list_widget.dart';

class ChaletsPageWidget extends StatefulWidget {
  final List<Chalet> chalets;
  final bool chaletsStateIsEmpty;
  final BuildContext buildContext;
  ChaletsPageWidget(
      {required this.chalets,
      required this.chaletsStateIsEmpty,
      required this.buildContext});
  @override
  State<ChaletsPageWidget> createState() => _ChaletsPageWidgetState();
}

class _ChaletsPageWidgetState extends State<ChaletsPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: Container(
        padding: const EdgeInsets.all(5),
        color: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            ActionBtn(onPressed: (){
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const ChaletFilterPage(filterType: "date",),
                withNavBar: false,
              );
            }, btnTitle: getTextByKey(key: TranslationKey.keyChaletsByDates), btnColor: Colors.grey.shade500),
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Row(
                  //   children: [
                  //     GestureDetector(
                  //       child: TextIcon(
                  //           text: getTextByKey(key: TranslationKey.keyPrice),
                  //           imagePath: AssetsPath.sortImg),
                  //       onTap: () {
                  //         CommonFunctions.pageNumberChalets = 1;
                  //         CommonFunctions.fromHighToLowPrice =
                  //             !CommonFunctions.fromHighToLowPrice;
                  //         CommonFunctions.fromHighToLowRate = false;
                  //
                  //         widget.chalets.clear();
                  //
                  //         BlocProvider.of<ChaletsBloc>(context).add(GetAllChaletsEvent(
                  //             pageNumber: CommonFunctions.pageNumberChalets,
                  //             body: {
                  //               "page": 1,
                  //               "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
                  //               "heightolow":   CommonFunctions.fromHighToLowPrice
                  //                   ? 1
                  //                   : 2,
                  //               "rateheightolow": 0
                  //             }));
                  //       },
                  //     )
                  //   ],
                  // ),
                  // Container(
                  //   height: 30,
                  //   width: 1,
                  //   color: Colors.grey.shade500,
                  // ),
                  GestureDetector(
                    child: TextIcon(
                        text: getTextByKey(key: TranslationKey.keyFilter),
                        imagePath: AssetsPath.filter),
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const ChaletFilterPage(filterType: "normal"),
                        withNavBar: false,
                      );
                    },
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.grey.shade500,
                  ),
                 GestureDetector(onTap: (){
                   BlocProvider.of<ChaletsBloc>(context).add(
                       GetAllChaletsMapEvent(
                          ));
                   PersistentNavBarNavigator.pushNewScreen(
                     context,
                     screen: ChaletsMapScreen(),
                     withNavBar: false,
                   );
                 },child: TextIcon(
                      text: getTextByKey(key: TranslationKey.keyMap),
                      imagePath: AssetsPath.map)
                 ) ],
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            // Container(
            //   padding: const EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //       color: Colors.blueGrey.shade50,
            //       borderRadius:
            //           const BorderRadius.all(Radius.circular(DEFAULT_CORNER))),
            //   child: Row(children: [
            //     Text(
            //       getTextByKey(
            //           key: CommonFunctions.fromHighToLowPrice
            //               ? TranslationKey.keyHighLowPrice
            //               : TranslationKey.keyLowHighPrice),
            //       style: TextStyles.textStyleHelper(context)
            //           .copyWith(color: primaryColor),
            //     ),
            //   ]),
            // ),

            Expanded(
              child: ChaletListWidget(
                chalets: widget.chalets,
                lastEmpty: widget.chaletsStateIsEmpty ? true : false,
              ),
            )
          ],
        ),
      ))
    ]);
  }
}
