import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/features/buildings/presentation/bloc/flat/flats_bloc.dart';

import '../../../../../core/network/urls.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/styles/text/text_style.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/favorites/favorite_item.dart';
import '../../../../../core/widgets/favorite_button.dart';
import '../../../../../core/widgets/today_offer_widgets.dart';
import '../../../domain/entities/building.dart';
import '../../bloc/buildings/buildings_bloc.dart';
import '../../pages/building_detail_page.dart';

/// Local-favorites snapshot for a building — mirrors _chaletFavoriteItem in
/// chalet_card.dart.
FavoriteItem _buildingFavoriteItem(Building building) {
  final state = statesEnglishToArabic["${building.state}"] ?? "";
  final gov = building.governorate == "Dohfar" || building.governorate == "Dhofar"
      ? "ظفار"
      : building.governorate;
  return FavoriteItem(
    id: '${building.id}',
    type: 'building',
    name: building.name,
    image: building.image,
    price: building.minimumRent,
    location: state.isEmpty ? gov : (gov.isEmpty ? state : '$state $gov'),
  );
}

/// Modern building card.
///
/// The photo shows a governorate/location badge plus a favorite heart
/// button (backed by FavoritesCubit / local storage — no backend needed).
/// Price row shows a "starting from" label next to the amount, and each
/// card has a light fade + slide-up entrance animation.
Widget buildBuildingCard(
    BuildContext context,
    int index,
    Building building,
    bool isLastItem,
    bool? lastEmpty,
    ) {
  return Column(
    children: [
      // ── Light entrance animation (fade + slide up) ──
      TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 350 + (index * 40)),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: _BuildingCard(building: building),
      ),
      if (isLastItem && (lastEmpty == false))
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
    ],
  );
}

class _BuildingCard extends StatefulWidget {
  final Building building;

  const _BuildingCard({Key? key, required this.building}) : super(key: key);

  @override
  State<_BuildingCard> createState() => _BuildingCardState();
}

class _BuildingCardState extends State<_BuildingCard> {
  void _openDetails(BuildContext context) {
    BlocProvider.of<BuildingsBloc>(context)
        .add(LoadBuildingsById(id: widget.building.id.toString()));

    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: BuildingDetailPage(buildingId: widget.building.id.toString()),
      withNavBar: false,
    );
  }

  String _locationText(Building building) {
    final state = statesEnglishToArabic["${building.state}"] ?? "";
    final gov = building.governorate == "Dohfar" ||
        building.governorate == "Dhofar"
        ? "ظفار"
        : building.governorate;
    if (state.isEmpty) return gov;
    if (gov.isEmpty) return state;
    return "$state | $gov";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openDetails(context),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Photo ──
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: CachedNetworkImage(
                          imageUrl: widget.building.image,
                          fit: BoxFit.cover,
                          memCacheWidth: 800,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFF5F5F5),
                            child: const Icon(Icons.image_outlined,
                                color: Color(0xFFBDBDBD), size: 28),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFF5F5F5),
                            child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Color(0xFFBDBDBD),
                                size: 28),
                          ),
                        ),
                      ),
                    ),

                    // ── Governorate / location badge — the only
                    // overlay on the photo right now ──
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 13, color: Color(0xFF6C757D)),
                            const SizedBox(width: 4),
                            Text(
                              _locationText(widget.building),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF3C4043),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Favorite button — persisted locally via
                    // FavoritesCubit, no backend involved. ──
                    Positioned(
                      top: 12,
                      right: 12,
                      child: FavoriteButton(item: _buildingFavoriteItem(widget.building)),
                    ),

                    // ── Today's Offer badge — bottom-left over the photo,
                    // only when the owner's last-minute discount applies
                    // today. ──
                    if (widget.building.todayOfferActive)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: TodayOfferBadge(
                            percent: widget.building.todayOfferPercent),
                      ),
                  ],
                ),

                // ── Content below the photo ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.building.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.textStyleTitle(context)
                                  .copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // "Starting from" label + price
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  getTextByKey(
                                      key: TranslationKey.keyStartFrom),
                                  style: const TextStyle(
                                    color: Color(0xFF9AA0A6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.building.minimumRent,
                                  style: TextStyles.textStyleHeadline(context)
                                      .copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  getTextByKey(key: TranslationKey.keyOMR),
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Circular accent CTA
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}