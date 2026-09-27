import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../../core/network/urls.dart';
import '../../../../../core/strings/language.dart';
import '../../../../../core/styles/app_theme.dart';
import '../../../../../core/styles/text/text_style.dart';
import '../../../../../core/util/Constants.dart';
import '../../../../../core/favorites/favorite_item.dart';
import '../../../../../core/widgets/favorite_button.dart';
import '../../../../../core/widgets/today_offer_widgets.dart';
import '../../../../../core/util/characteristics_translator.dart';
import '../../../domain/entities/chalet.dart';
import '../../bloc/chalets/chalets_bloc.dart';
import '../../pages/chalet_detail_page.dart';

// Shared accent color for the new structured-field chips / badges below.
// Matches the primary brand color already used on the chalet detail
// screen (Color(0xFF6366F1)), so the card feels consistent with the rest
// of the app rather than introducing a random new color.
const Color _cardAccentColor = Color(0xFF6366F1);

Widget buildChaletCard(
    BuildContext context,
    int index,
    Chalet chalet,
    bool isLastItem,
    bool? lastEmpty,
    ) {
  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: Duration(milliseconds: 400 + (index * 50)),
    builder: (context, value, child) {
      return Transform.translate(
        offset: Offset(0, 16 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      );
    },
    child: Column(
      children: [
        // Card Body - Now Responsive
        LayoutBuilder(
          builder: (context, constraints) {
            return _ResponsiveChaletCardWidget(
              chalet: chalet,
              constraints: constraints,
            );
          },
        ),
        // Loader (Simplified null-safe check)
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
    ),
  );
}

// Maps the English chaletType value the API sends (e.g. "Chalet") back to
// the Arabic label shown to the user. Returns null (renders nothing) when
// chaletType is null/empty — this field is one of the ones the list
// endpoint may or may not include, and older chalets predate it entirely.
const Map<String, String> _cardTypeArabicLabels = {
  'Chalet': 'شاليه',
  'Resort': 'استراحة',
  'Hut': 'كوخ',
};

String? _typeLabel(Chalet chalet) {
  final type = chalet.chaletType;
  if (type == null || type.isEmpty) return null;
  return _cardTypeArabicLabels[type] ?? type;
}

/// landscape comes back as a comma-separated list — sometimes already
/// Arabic ("ساحلي (قرب البحر), جبلي (جبال وطبيعة)"), sometimes the raw
/// English enum key the owner apps actually store ("coastal", or even a
/// mistyped "Costal") when it was saved through the fixed-choice list
/// instead of free text. Either way this keeps only the first tag,
/// translates it if needed, and drops any parenthetical note — to fit a
/// single short chip.
String? _firstLandscapeTag(Chalet chalet) {
  final landscape = chalet.landscape;
  if (landscape == null || landscape.isEmpty) return null;
  final first = landscape.split(',').first.trim();
  if (first.isEmpty) return null;
  final shortTag = translateCharacteristicTokenShort(first);
  return shortTag.isEmpty ? null : shortTag;
}

/// Parses a price string (may contain commas, e.g. "1,250") into a double,
/// or null if it isn't a usable number. Used to compute the discounted
/// today's-offer price client-side from the base nightly rate.
double? _parsePrice(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return double.tryParse(raw.replaceAll(',', '').trim());
}

/// Formats a computed price without a trailing ".00" when it's a whole
/// number, matching how the API's plain price strings normally look.
String _formatOfferPrice(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}

/// Safely turns the dynamic rateAverage field into a double, or null if
/// it's missing/zero/unparseable. Kept defensive since the field is
/// typed `dynamic` on the model and its shape isn't guaranteed.
double? _ratingValue(Chalet chalet) {
  final raw = chalet.rateAverage;
  double? value;
  if (raw is num) {
    value = raw.toDouble();
  } else if (raw != null) {
    value = double.tryParse(raw.toString());
  }
  if (value == null || value <= 0) return null;
  return value;
}

/// Whether there's anything to show in the quick-facts row at all. Used
/// both to decide whether to render the row and whether to grow the
/// card's height slightly to fit it — chalets without these fields keep
/// the original compact card size instead of wasting space.
/// chaletType is intentionally excluded here — it now gets its own chip
/// (and its own reserved height) right under the name via
/// _buildTypeChip, separate from this capacity/bedrooms/landscape row.
/// minDays only counts when the chalet is actually bookable (stopBook
/// isn't true) — showing "min 2 nights" on a chalet that can't be booked
/// at all is just noise — and only when > 1, since every booking is at
/// least 1 night anyway.
bool _hasQuickFacts(Chalet chalet) {
  return (chalet.capacity?.isNotEmpty ?? false) ||
      (chalet.bedrooms?.isNotEmpty ?? false) ||
      (_firstLandscapeTag(chalet) != null) ||
      (chalet.stopBook != true && (chalet.minDays ?? 0) > 1);
}

/// Compact row of quick facts (capacity / bedrooms / landscape / min
/// nights) built from the new structured API fields. chaletType is shown
/// as its own chip right under the name instead (see _buildTypeChip), so
/// it's excluded here. Every piece is independently optional — whatever
/// is missing is simply skipped, so this degrades gracefully for older
/// chalets or the list endpoint's trimmed payload instead of showing
/// "null" or breaking layout.
Widget _buildQuickFacts(Chalet chalet) {
  final chips = <Widget>[];

  if (chalet.capacity != null && chalet.capacity!.isNotEmpty) {
    chips.add(_quickFactChip(Icons.people_alt_rounded, chalet.capacity!));
  }
  if (chalet.bedrooms != null && chalet.bedrooms!.isNotEmpty) {
    chips.add(_quickFactChip(Icons.bed_rounded, chalet.bedrooms!));
  }
  final landscapeTag = _firstLandscapeTag(chalet);
  if (landscapeTag != null) {
    chips.add(_quickFactChip(Icons.landscape_rounded, landscapeTag));
  }
  if (chalet.stopBook != true && (chalet.minDays ?? 0) > 1) {
    chips.add(_quickFactChip(Icons.nightlight_round, 'الحد الأدنى ${chalet.minDays} ليالٍ'));
  }

  if (chips.isEmpty) return const SizedBox.shrink();

  return Wrap(
    spacing: 8,
    runSpacing: 4,
    children: chips,
  );
}

/// A small icon-in-circle + label, lighter and a bit more polished than a
/// plain text pill — used for capacity / bedrooms / landscape.
Widget _quickFactChip(IconData icon, String value) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _cardAccentColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 10, color: _cardAccentColor),
      ),
      const SizedBox(width: 4),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF495057),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

/// The chalet type (شاليه / استراحة / كوخ) shown as its own small colored
/// chip right under the name — more readable there than as tiny text
/// overlaid on a photo of unpredictable color/contrast. Renders nothing
/// when chaletType is absent.
Widget _buildTypeChip(Chalet chalet) {
  final label = _typeLabel(chalet);
  if (label == null) return const SizedBox.shrink();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: _cardAccentColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: _cardAccentColor,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// Small pill on the image (top-left, mirrors the rating badge's style
/// bottom-right) shown when the owner has locked bookings for this
/// chalet (chalet.stopBook == true). Deliberately understated and short
/// — the full owner-facing message is too long to fit legibly on a
/// small thumbnail, so the complete sentence lives in
/// _buildUnavailableNotice below instead, in the wider content column.
/// Renders nothing when stopBook isn't true, so a missing/null value
/// (older payloads that don't send it) is treated the same as
/// "bookable".
Widget _buildUnavailableBadge(Chalet chalet) {
  if (chalet.stopBook != true) return const SizedBox.shrink();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.event_busy_rounded, size: 12, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          'غير متاح',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    ),
  );
}

/// The full message — "غير متاح للحجز من المالك في الوقت الحالي" — shown
/// as a small wrapped notice in the content column (much wider than the
/// thumbnail, so the sentence actually fits in 1-2 lines instead of
/// getting crushed into a corner pill). Renders nothing when stopBook
/// isn't true.
Widget _buildUnavailableNotice(Chalet chalet) {
  if (chalet.stopBook != true) return const SizedBox.shrink();

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.event_busy_rounded, size: 12, color: Colors.red.shade400),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            'غير متاح للحجز من المالك في الوقت الحالي',
            softWrap: true,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade400,
              height: 1.3,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Builds the local FavoriteItem snapshot for a chalet — enough info to
/// render it later in the Favorites tab without another network call.
FavoriteItem _chaletFavoriteItem(Chalet chalet) {
  return FavoriteItem(
    id: '${chalet.id}',
    type: 'chalet',
    name: chalet.name,
    image: BASE_URL + chalet.image,
    price: chalet.rentFullday,
    location: '${statesEnglishToArabic["${chalet.state}"] ?? ""} ${governoratesEnglishToArabic[chalet.governorate] ?? ""}'.trim(),
    rating: _ratingValue(chalet),
  );
}

/// Small rating pill overlaid on the image (star + rateAverage). Renders
/// nothing when there's no usable rating.
Widget _buildRatingBadge(Chalet chalet) {
  final rating = _ratingValue(chalet);
  if (rating == null) return const SizedBox.shrink();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFB100)),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F2E),
          ),
        ),
      ],
    ),
  );
}

/// Internal Widget for Responsive Card
class _ResponsiveChaletCardWidget extends StatelessWidget {
  final Chalet chalet;
  final BoxConstraints constraints;

  const _ResponsiveChaletCardWidget({
    Key? key,
    required this.chalet,
    required this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine card dimensions based on screen width
    late double cardHeight;
    late double imageWidth;
    late double padding;
    late double spacing;

    if (screenWidth < 360) {
      // Small Phone
      cardHeight = 128;
      imageWidth = 92;
      padding = 10;
      spacing = 10;
    } else if (screenWidth < 600) {
      // Medium Phone
      cardHeight = 148;
      imageWidth = 110;
      padding = 12;
      spacing = 12;
    } else if (screenWidth < 900) {
      // Large Phone
      cardHeight = 172;
      imageWidth = 126;
      padding = 14;
      spacing = 14;
    } else {
      // Tablet
      cardHeight = 188;
      imageWidth = 148;
      padding = 14;
      spacing = 16;
    }

    // Grow the card just enough to fit the quick-facts row when it's
    // present — chalets without capacity/bedrooms/landscape keep the
    // original compact height, so this stays light by default. Same
    // idea for the type chip under the name.
    final hasQuickFacts = _hasQuickFacts(chalet);
    final hasTypeLabel = _typeLabel(chalet) != null;

    // Today's Offer — compute the discounted first-night rate so the
    // price row itself can sell the deal (strikethrough original +
    // highlighted discounted price), not just a small corner badge.
    final baseRate = _parsePrice(chalet.rentFullday);
    final showOfferPrice = chalet.todayOfferActive && baseRate != null;
    final offerPrice =
        showOfferPrice ? baseRate! * (1 - chalet.todayOfferPercent / 100) : null;

    final effectiveCardHeight = cardHeight +
        (hasQuickFacts ? 22 : 0) +
        (hasTypeLabel ? 20 : 0) +
        (chalet.stopBook == true ? 34 : 0) +
        (showOfferPrice ? 16 : 0);

    // Softly mute the whole card (not just the image) when bookings are
    // locked — a light "greyed out" cue instead of a heavy overlay.
    return Opacity(
      opacity: chalet.stopBook == true ? 0.65 : 1.0,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to chalet detail page
            BlocProvider.of<ChaletsBloc>(context)
                .add(LoadChaletsById(id: "${chalet.id}"));
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: ChaletDetailPage(chaletId: "${chalet.id}"),
              withNavBar: false,
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: effectiveCardHeight,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              border: Border.all(color: Colors.grey.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image + overlay badges (type / rating)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: imageWidth,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: BASE_URL + chalet.image,
                          fit: BoxFit.cover,
                          // Card thumbnail is only ~150 logical px wide —
                          // without this, cached_network_image decodes the
                          // full source photo (often several MB / dozens of
                          // MB as a raw bitmap) for every card on screen,
                          // which is what was blowing out GPU/memory on
                          // low-end devices while scrolling long lists.
                          memCacheWidth: 300,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[100],
                            child: const Icon(Icons.downloading, size: 30),
                          ),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                        ),
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: _buildRatingBadge(chalet),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: FavoriteButton(item: _chaletFavoriteItem(chalet)),
                        ),
                        // Compact variant — the full pill ("خصم 20%
                        // اليوم") was wide enough to visually overlap the
                        // favorite button on the opposite corner of these
                        // narrow thumbnails (as little as 92px wide on
                        // small phones). Compact drops to "-20%" so both
                        // corners stay clear of each other.
                        if (chalet.todayOfferActive)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: TodayOfferBadge(
                              percent: chalet.todayOfferPercent,
                              compact: true,
                            ),
                          ),
                        // Positioned(
                        //   top: 6,
                        //   left: 6,
                        //   child: _buildUnavailableBadge(chalet),
                        // ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: spacing),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Name
                      Text(
                        chalet.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.textStyleButton(context)
                            .copyWith(color: Colors.black),
                      ),
                      if (_typeLabel(chalet) != null) ...[
                        SizedBox(height: spacing * 0.4),
                        _buildTypeChip(chalet),
                      ],
                      SizedBox(height: spacing * 0.7),

                      // Location Badge
                      Row(
                        children: [
                          Flexible(
                            child: _buildLocationBadge(
                              icon: Icons.pin_drop_rounded,
                              text: _getLocationText(chalet),
                            ),
                          ),
                        ],
                      ),

                      // Quick facts (capacity / bedrooms / landscape) —
                      // only takes space when at least one is available.
                      if (hasQuickFacts) ...[
                        SizedBox(height: spacing * 0.6),
                        _buildQuickFacts(chalet),
                      ],
                      if (chalet.stopBook == true) ...[
                        SizedBox(height: spacing * 0.6),
                        _buildUnavailableNotice(chalet),
                      ],
                      SizedBox(height: spacing * 0.7),
                      Divider(height: 1, color: Colors.grey.shade100),
                      SizedBox(height: spacing * 0.5),

                      // Price Info — when today's offer applies, this
                      // becomes the main sales pitch: the original rate
                      // struck through above a highlighted discounted
                      // rate, instead of a single plain price the offer
                      // badge alone had to speak for.
                      if (showOfferPrice && offerPrice != null) ...[
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                getTextByKey(key: TranslationKey.keyStartFrom),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.textStyleHelper(context),
                              ),
                            ),
                            SizedBox(width: spacing * 0.4),
                            Flexible(
                              child: Text(
                                chalet.rentFullday,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: spacing * 0.15),
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded,
                                size: 14, color: TodayOfferColors.primary),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                _formatOfferPrice(offerPrice),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.textStyleHeadline(context)
                                    .copyWith(color: TodayOfferColors.primary),
                              ),
                            ),
                            SizedBox(width: spacing * 0.4),
                            Flexible(
                              child: Text(
                                getTextByKey(key: TranslationKey.keyOMR),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.textStyleTitle(context)
                                    .copyWith(color: TodayOfferColors.primary),
                              ),
                            ),
                            SizedBox(width: spacing * 0.4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: TodayOfferColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'اليوم فقط',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: TodayOfferColors.dark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                getTextByKey(
                                  key: TranslationKey.keyStartFrom,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.textStyleHelper(context),
                              ),
                            ),
                            SizedBox(width: spacing * 0.5),
                            Flexible(
                              child: Text(
                                chalet.rentFullday,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.textStyleHeadline(context)
                                    .copyWith(color: yellowAppColor),
                              ),
                            ),
                            SizedBox(width: spacing * 0.5),
                            Flexible(
                              child: Text(
                                getTextByKey(key: TranslationKey.keyOMR),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.textStyleTitle(context)
                                    .copyWith(color: yellowAppColor),
                              ),
                            ),
                          ],
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

  /// Get location text from chalet data
  String _getLocationText(Chalet chalet) {
    final state = statesEnglishToArabic["${chalet.state}"] ?? "";
    final gov =
        governoratesEnglishToArabic[chalet.governorate] ?? "";
    if (state.isEmpty) return gov;
    if (gov.isEmpty) return state;
    return "$state | $gov";
  }
}

/// Location Badge Widget
///
/// Shows location with icon in a pill-shaped badge
Widget _buildLocationBadge({
  required IconData icon,
  required String text,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF6C757D)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF495057),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

// ============================================
// ALTERNATIVE IMPLEMENTATION (Simple Version)
// Use this if you prefer a simpler approach
// ============================================

/// Alternative simple responsive card builder
///
/// This version uses if-else conditions instead of LayoutBuilder
/// Choose whichever style you prefer
Widget buildResponsiveChaletCard(
    BuildContext context,
    int index,
    Chalet chalet,
    bool isLastItem,
    bool? lastEmpty,
    ) {
  final screenWidth = MediaQuery.of(context).size.width;

  return TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0, end: 1),
    duration: Duration(milliseconds: 400 + (index * 50)),
    builder: (context, value, child) {
      return Transform.translate(
        offset: Offset(0, 16 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      );
    },
    child: Column(
      children: [
        // Automatically choose card variant based on screen width
        if (screenWidth < 360)
          _buildChaletCardVariant(
            context: context,
            chalet: chalet,
            cardHeight: 128,
            imageWidth: 92,
            padding: 10,
            spacing: 10,
          )
        else if (screenWidth < 600)
          _buildChaletCardVariant(
            context: context,
            chalet: chalet,
            cardHeight: 148,
            imageWidth: 110,
            padding: 12,
            spacing: 12,
          )
        else if (screenWidth < 900)
            _buildChaletCardVariant(
              context: context,
              chalet: chalet,
              cardHeight: 172,
              imageWidth: 126,
              padding: 14,
              spacing: 14,
            )
          else
            _buildChaletCardVariant(
              context: context,
              chalet: chalet,
              cardHeight: 188,
              imageWidth: 148,
              padding: 14,
              spacing: 16,
            ),
        // Loading indicator
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
    ),
  );
}

/// Helper to build card with specific dimensions
Widget _buildChaletCardVariant({
  required BuildContext context,
  required Chalet chalet,
  required double cardHeight,
  required double imageWidth,
  required double padding,
  required double spacing,
}) {
  final hasQuickFacts = _hasQuickFacts(chalet);
  final hasTypeLabel = _typeLabel(chalet) != null;
  final effectiveCardHeight = cardHeight +
      (hasQuickFacts ? 22 : 0) +
      (hasTypeLabel ? 20 : 0) +
      (chalet.stopBook == true ? 34 : 0);

  // Softly mute the whole card when bookings are locked — a light
  // "greyed out" cue instead of a heavy overlay.
  return Opacity(
    opacity: chalet.stopBook == true ? 0.65 : 1.0,
    child: Material(
      borderRadius: BorderRadius.circular(20),
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          BlocProvider.of<ChaletsBloc>(context)
              .add(LoadChaletsById(id: "${chalet.id}"));
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: ChaletDetailPage(chaletId: "${chalet.id}"),
            withNavBar: false,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: effectiveCardHeight,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image + overlay badges (type / rating)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: imageWidth,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: BASE_URL + chalet.image,
                        fit: BoxFit.cover,
                        memCacheWidth: 300,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.downloading, size: 30),
                        ),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: _buildRatingBadge(chalet),
                      ),
                      // Positioned(
                      //   top: 6,
                      //   left: 6,
                      //   child: _buildUnavailableBadge(chalet),
                      // ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: spacing),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name
                    Text(
                      chalet.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.textStyleButton(context)
                          .copyWith(color: Colors.black),
                    ),
                    if (_typeLabel(chalet) != null) ...[
                      SizedBox(height: spacing * 0.4),
                      _buildTypeChip(chalet),
                    ],
                    SizedBox(height: spacing * 0.7),

                    // Location
                    Row(
                      children: [
                        Flexible(
                          child: _buildLocationBadge(
                            icon: Icons.pin_drop_rounded,
                            text: _getLocationTextHelper(chalet),
                          ),
                        ),
                      ],
                    ),

                    // Quick facts (capacity / bedrooms / landscape) — only
                    // takes space when at least one is available.
                    if (hasQuickFacts) ...[
                      SizedBox(height: spacing * 0.6),
                      _buildQuickFacts(chalet),
                    ],
                    if (chalet.stopBook == true) ...[
                      SizedBox(height: spacing * 0.6),
                      _buildUnavailableNotice(chalet),
                    ],
                    SizedBox(height: spacing * 0.7),
                    Divider(height: 1, color: Colors.grey.shade100),
                    SizedBox(height: spacing * 0.5),

                    // Price Info
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            getTextByKey(key: TranslationKey.keyStartFrom),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.textStyleHelper(context),
                          ),
                        ),
                        SizedBox(width: spacing * 0.5),
                        Flexible(
                          child: Text(
                            chalet.rentFullday,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.textStyleHeadline(context)
                                .copyWith(color: yellowAppColor),
                          ),
                        ),
                        SizedBox(width: spacing * 0.5),
                        Flexible(
                          child: Text(
                            getTextByKey(key: TranslationKey.keyOMR),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.textStyleTitle(context)
                                .copyWith(color: yellowAppColor),
                          ),
                        ),
                      ],
                    )
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

/// Helper function for location text
String _getLocationTextHelper(Chalet chalet) {
  final state = statesEnglishToArabic["${chalet.state}"] ?? "";
  final gov = chalet.governorate == "Dohfar" ? "ظفار" : chalet.governorate;
  if (state.isEmpty) return gov;
  if (gov.isEmpty) return state;
  return "$state | $gov";
}

// ============================================
// MODELS & IMPORTS (Replace with your actual imports)
// ============================================

// TODO: Replace these with your actual imports

