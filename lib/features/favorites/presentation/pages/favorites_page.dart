import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../core/favorites/favorite_item.dart';
import '../../../../core/favorites/favorites_cubit.dart';
import '../../../../core/strings/language.dart';
import '../../../../core/styles/app_theme.dart';
import '../../../../core/styles/text/text_style.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../buildings/presentation/bloc/buildings/buildings_bloc.dart';
import '../../../buildings/presentation/pages/building_detail_page.dart';
import '../../../chalets/presentation/bloc/chalets/chalets_bloc.dart';
import '../../../chalets/presentation/pages/chalet_detail_page.dart';

/// Local-only favorites tab — everything here comes from FavoritesCubit's
/// in-memory list (backed by shared_preferences), no network call involved.
/// Tapping a saved item re-dispatches the same Load-by-id event the regular
/// chalet/building cards use, so the detail page behaves identically either
/// way.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'المفضلة',
                  style: TextStyles.textStyleHeadline(context)
                      .copyWith(fontWeight: FontWeight.w800, color: Colors.black),
                ),
              ),
              Expanded(
                child: BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, state) {
                    // Was just checking items.isEmpty before, so a slow or
                    // silently-failed fetch looked identical to "genuinely
                    // no favorites" — no spinner, no error, nothing. Now
                    // loading gets its own spinner instead of flashing the
                    // "no favorites yet" message while the request is
                    // still in flight.
                    if (state.isLoading && state.items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.items.isEmpty) {
                      return const _EmptyFavorites();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(milliseconds: 300 + (index * 40)),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 12 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: _FavoriteCard(item: item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Friendly empty state that also teaches the user how favorites work —
/// there's no other hint anywhere else in the app that the heart icon on
/// cards does anything, so this is the one place that explains it.
class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_border_rounded, size: 46, color: primaryColor),
            ),
            const SizedBox(height: 20),
            Text(
              'لا يوجد لديك عناصر مفضلة بعد',
              style: TextStyles.textStyleTitle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'اضغط على أيقونة القلب الموجودة على أي شاليه أو شقة لإضافته هنا، وارجع إليه بسهولة في أي وقت',
              style: TextStyles.textStyleHelper(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteItem item;

  const _FavoriteCard({Key? key, required this.item}) : super(key: key);

  void _openDetails(BuildContext context) {
    if (item.isChalet) {
      context.read<ChaletsBloc>().add(LoadChaletsById(id: item.id));
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: ChaletDetailPage(chaletId: item.id),
        withNavBar: false,
      );
    } else {
      context.read<BuildingsBloc>().add(LoadBuildingsById(id: item.id));
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: BuildingDetailPage(buildingId: item.id),
        withNavBar: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openDetails(context),
        child: Container(
          padding: const EdgeInsets.all(12),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail with the type badge (شاليه/شقة) and the favorite
              // heart overlaid on it — matches the visual language of the
              // main chalet/building cards instead of a separate row item.
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.image,
                        fit: BoxFit.cover,
                        memCacheWidth: 240,
                        placeholder: (context, url) => Container(color: Colors.grey[100]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: FavoriteButton(item: item, size: 15),
                      ),
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.isChalet ? 'شاليه' : 'شقة',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.textStyleButton(context)
                          .copyWith(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    if (item.location.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pin_drop_rounded, size: 13, color: Color(0xFF9AA0A6)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFF6C757D), fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: yellowAppColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              item.price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.textStyleHeadline(context)
                                  .copyWith(color: yellowAppColor, fontWeight: FontWeight.w800, fontSize: 13.5),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            getTextByKey(key: TranslationKey.keyOMR),
                            style: TextStyle(color: yellowAppColor, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }
}
