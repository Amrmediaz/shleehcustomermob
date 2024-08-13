import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shleehcustomer/core/strings/assets_path.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/home_page/presentation/bloc/home/home_bloc.dart';

import '../../../../../core/network/urls.dart';
import '../../../../../core/util/common_functions.dart';
import '../../../../../core/widgets/loading_image.dart';
import '../../pages/chalet_detail_page.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/chalet.dart';

class ChaletListWidget extends StatelessWidget {
  final List<Chalet> chalets;
  final bool lastEmpty;
  const ChaletListWidget({
    Key? key,
    required this.chalets,
    required this.lastEmpty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: chalets.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        bool isLastItem = index == chalets.length - 1;
        if (isLastItem && !lastEmpty) {
          CommonFunctions.pageNumberChalets =
              CommonFunctions.pageNumberChalets + 1;
          BlocProvider.of<ChaletsBloc>(context).add(GetAllChaletsEvent(
              pageNumber: CommonFunctions.pageNumberChalets,
              body: {
                "page": CommonFunctions.pageNumberChalets,
                "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
                "heightolow":  1,
                "rateheightolow": 0
              }));


        } else {}
        return Material(

            borderRadius:
            const BorderRadius.all(Radius.circular(DEFAULT_CORNER)),
        child:  InkWell(
          onTap: () {
            // BlocProvider.of<HomeBloc>(context)
            //     .add(HideBottomBarEvent(true));

            BlocProvider.of<ChaletsBloc>(context)
                .add(LoadChaletsById(id: "${chalets[index].id}"));
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: ChaletDetailPage(),
              withNavBar: false,
            );
          },
          child: Column(children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(DEFAULT_CORNER - 7),
                  child:
                  CachedNetworkImage(
                    imageUrl: BASE_URL + chalets[index].image,
                    height: MediaQuery.of(context).size.height / 9,
                    width: MediaQuery.of(context).size.height / 9,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Icon(Icons.downloading,color: Colors.grey.shade100,size: 50,),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),

                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(chalets[index].name,
                          style: TextStyles.textStyleButton(context)
                              .copyWith(color: Colors.black)),


                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(getTextByKey(key: TranslationKey.keyStartFrom),
                              style: TextStyles.textStyleHelper(context)),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            chalets[index].rentFullday,
                            style: TextStyles.textStyleHeadline(context)
                                .copyWith(color: yellowAppColor),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            getTextByKey(key: TranslationKey.keyOMR),
                            style: TextStyles.textStyleTitle(context)
                                .copyWith(color: yellowAppColor),
                          ),
                        ],
                      ) ,
                      Text( getTextByKey(key: chalets[index].state),
                          style: TextStyles.textStyleButton(context)
                              .copyWith(color: yellowAppColor   )),
                    ],
                  ),
                )
              ],
            ),
            isLastItem && !lastEmpty
                ? const SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  )
                : Container()
          ]),
        ));
      },
      separatorBuilder: (context, index) => Divider(
        thickness: 1,
        color: Colors.grey.shade200,
      ),
    );
  }
}
