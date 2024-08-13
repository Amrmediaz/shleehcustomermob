import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shleehcustomer/core/network/urls.dart';
import 'package:shleehcustomer/core/strings/assets_path.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/core/widgets/action_btn.dart';
import 'package:shleehcustomer/features/booking/presentation/pages/chalet_booking_date_page.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/chalet_detail_page/price_Widgets/list_price_widget.dart';

import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/util/cashed_data/cashed_file.dart';
import '../../../domain/entities/chalet_details_model.dart';

class ChaletDetailWidget extends StatefulWidget {
  final ChaletDetails chalet;

  const ChaletDetailWidget({
    Key? key,
    required this.chalet,
  }) : super(key: key);

  @override
  _ChaletDetailWidgetState createState() => _ChaletDetailWidgetState();
}

List<Map<String, dynamic>> removeDuplicates(
    List<Map<String, dynamic>> services) {
  Set<String> seenServices = Set();
  List<Map<String, dynamic>> uniqueServices = [];

  for (var service in services) {
    if (!seenServices.contains(service['serviceName']) &&
        service['serviceName'] != "") {
      seenServices.add(service['serviceName']);
      if (service['serviceName'] != "noSmoking" || service['serviceName'] != "")
        uniqueServices.add(service);
    }
  }

  return uniqueServices;
}

class _ChaletDetailWidgetState extends State<ChaletDetailWidget> {
  var isClicked = "description";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkDeviceType();
    widget.chalet.buldingService =
        removeDuplicates(widget.chalet.buldingService);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image at the top

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
            ),
            child: SizedBox(
              height: !CasheFile.isTablet ? 300 : 700,
              child: PageView.builder(
                itemCount: widget.chalet.buldingImages.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: BASE_URL +
                        widget.chalet.buldingImages[index]["path"].toString(),
                    fit: BoxFit.fill,
                    placeholder: (context, url) => Icon(
                      Icons.downloading,
                      color: Colors.grey.shade100,
                      size: 70,
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  );
                },
              ),
            ),
          ),
        ),

        Positioned(
          top: CommonFunctions.getSafeAreaTip(context),
          left: CasheFile.isTablet ? 30 : 20,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: SvgPicture.asset(
              AssetsPath.backSvg,
              width: CasheFile.isTablet ? 44 : null,
              // Replace with your image URL
              // Adjust the height as needed
            ),
          ),
        ),
        Positioned(
            top: CommonFunctions.getSafeAreaTip(context),
            right: CasheFile.isTablet ? 30 : 20,
            child: Card(
              child: GestureDetector(
                onTap: () async {
                  await CommonFunctions.openMap(
                      widget.chalet.lat, widget.chalet.lng);
                },
                child: SvgPicture.asset(
                  AssetsPath.map,
                  width: CasheFile.isTablet ? 64 : null,
                  // Replace with your image URL
                  // Adjust the height as needed
                ),
              ),
            )),

        // Container with top corner radius at the bottom
        Positioned(
          bottom: 0,
          left: 15,
          right: 15,
          top: !CasheFile.isTablet ? 260 : 600,
          child: Container(
              height: 200, // Adjust the height as needed
              decoration: const BoxDecoration(
                color: Colors.white, // Change color as needed
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0), // Adjust the radius as needed
                  topRight:
                      Radius.circular(25.0), // Adjust the radius as needed
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.chalet.name,
                          style: TextStyles.textStyleHeadline(context,
                              titleSizeFactor: CasheFile.isTablet ? 1.5 : 1.1)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(getTextByKey(key: TranslationKey.keyStartFrom),
                              style: TextStyles.textStyleHelper(context)),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            widget.chalet.rentFullday,
                            style: TextStyles.textStyleHeadline(context)
                                .copyWith(color: yellowAppColor),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            getTextByKey(key: TranslationKey.keyOMR),
                            style: TextStyles.textStyleBody(context)
                                .copyWith(color: yellowAppColor),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                              child: GestureDetector(
                                  onTap: () {
                                    isClicked = "description";
                                    setState(() {});
                                  },
                                  child: FrameBtn(
                                      title: getTextByKey(
                                          key: TranslationKey.keyDescription),
                                      isClicked: isClicked == "description"))),
                          const SizedBox(
                            width: 20,
                          ),
                          Flexible(
                              child: GestureDetector(
                                  onTap: () {
                                    isClicked = "terms";
                                    setState(() {});
                                  },
                                  child: FrameBtn(
                                      title: getTextByKey(
                                          key: TranslationKey.keyTerms),
                                      isClicked: isClicked == "terms"))),
                          const SizedBox(
                            width: 20,
                          ),
                          Flexible(
                              child: GestureDetector(
                                  onTap: () {
                                    isClicked = "prices";
                                    setState(() {});
                                  },
                                  child: FrameBtn(
                                      title: getTextByKey(
                                          key: TranslationKey.keyPrice),
                                      isClicked: isClicked == "prices")))
                        ],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      isClicked == "terms"
                          ? Text(
                              widget.chalet.note,
                              style: TextStyles.textStyleBody(context)
                                  .copyWith(color: greyColorTxt),
                            )
                          : isClicked == "description"
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.chalet.buldingDescrption,
                                      style: TextStyles.textStyleBody(context)
                                          .copyWith(color: greyColorTxt),
                                    ),
                                    const SizedBox(
                                      height: 35,
                                    ),
                                    Text(
                                      getTextByKey(
                                          key: TranslationKey
                                              .keyAvailableServices),
                                      style: TextStyles.textStyleTitle(context),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    GridView.count(
                                      childAspectRatio: 3,
                                      crossAxisCount: CasheFile.isTablet
                                          ? 3
                                          : 2, // Change this value to adjust the number of columns
                                      crossAxisSpacing: 8.0,
                                      mainAxisSpacing: 8.0,
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.all(0),
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: widget.chalet.buldingService
                                          .where((element) =>
                                              (element['serviceName'] !=
                                                  "wifi") &&
                                              element['serviceName']
                                                      .toString()
                                                      .toLowerCase() !=
                                                  "nosmoking" &&
                                              element["serviceName"] != "")
                                          .map<Widget>((Map service) {
                                        return SizedBox(
                                          width: double.infinity,
                                          height:
                                              30.0, // Adjust height as needed
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/chalets/${service["serviceName"].toLowerCase().replaceAll(' ', '_')}.svg',

                                                  width: CasheFile.isTablet
                                                      ? 66
                                                      : 36,
                                                  height: CasheFile.isTablet
                                                      ? 66
                                                      : 36,
                                                ),
                                                 SizedBox(width: CasheFile.isTablet ? 20.0 : 6.0),
                                                Flexible(
                                                  child: Text(
                                                    getTextByKey(
                                                        key: "key" +
                                                            service[
                                                                "serviceName"]),
                                                    style: TextStyles
                                                            .textStyleBody(
                                                                context)
                                                        .copyWith(
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                )
                              : isClicked == "prices"
                                  ? ListPriceWidget(chalet: widget.chalet)
                                  : Container(),
                      const SizedBox(
                        height: 100,
                      ),
                    ],
                  ),
                ),
              )),
        ),
        widget.chalet.stopBook
            ? Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "الحجز مفلق من قبل المالك",
                  style: TextStyles.textStyleTitle(context)
                      .copyWith(color: Colors.red),
                ))
            : Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: ActionBtn(
                      onPressed: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ChaletBookingPage(chalet: widget.chalet),
                          withNavBar: false,
                        );
                      },
                      btnTitle: TranslationKey.keyBook,
                      btnColor: primaryColor),
                ))
      ],
    );
  }

  void checkDeviceType() async {
    deviceType = await CommonFunctions().checkDeviceType(context);
    setState(() {});
  }

  var deviceType = "Phone";
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
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
          color: widget.isClicked ? primaryColor : GreyColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(DEFAULT_CORNER))),
      child: Text(widget.title,
          style: widget.isClicked
              ? TextStyles.textStyleButton(context, scaleFactor: 0.50)
              : TextStyles.textStyleHelper(context, scaleFactor: 0.60)
                  .copyWith(color: Colors.grey.shade500)),
    );
  }
}
