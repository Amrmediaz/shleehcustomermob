import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/strings/assets_path.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/home_page/presentation/bloc/home/home_bloc.dart';

import '../../../../../../core/network/urls.dart';
import '../../../../../../core/util/common_functions.dart';
import '../../../../../../core/favorites/favorite_item.dart';
import '../../../../../../core/widgets/favorite_button.dart';
import '../../../../domain/entities/chalet.dart';
import '../../../pages/chalet_detail_page.dart';

class ChaletByFilterListWidget extends StatefulWidget {
  final List<Chalet> chalets;
  final bool lastEmpty;
  final dynamic filterBody;

  const ChaletByFilterListWidget({
    Key? key,
    required this.chalets,
    required this.lastEmpty,
    required this.filterBody,
  }) : super(key: key);

  @override
  State<ChaletByFilterListWidget> createState() =>
      _ChaletByFilterListWidgetState();
}

/// Same local-favorites snapshot as the main chalet card — kept as its own
/// small helper here since this filter-results card is a separate, simpler
/// layout rather than reusing chalet_card.dart's widget.
FavoriteItem _chaletFavoriteItem(Chalet chalet) {
  return FavoriteItem(
    id: '${chalet.id}',
    type: 'chalet',
    name: chalet.name,
    image: BASE_URL + chalet.image,
    price: chalet.rentFullday,
    location: '${statesEnglishToArabic["${chalet.state}"] ?? ""} ${governoratesEnglishToArabic[chalet.governorate] ?? ""}'.trim(),
  );
}

class _ChaletByFilterListWidgetState extends State<ChaletByFilterListWidget> {
  final ScrollController _scrollController = ScrollController();

  // FIX: guards against firing the pagination event multiple times for
  // the same page while a request is still in flight. Previously the
  // event was dispatched as a side effect inside itemBuilder, which can
  // be invoked several times for the same "last" index during a single
  // scroll/layout pass, causing skipped/duplicate page requests.
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.lastEmpty || _isLoadingMore) return;

    const threshold = 200.0;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - threshold) {
      _isLoadingMore = true;
      CommonFunctions.pageNumberFilterChalets++;

      final body = <String, dynamic>{
        "page": CommonFunctions.pageNumberFilterChalets,
        "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
      };
      // FIX: carry the active filter (startDate/endDate/serviesList/etc.)
      // into every pagination request - previously this was omitted, so
      // page 2+ silently ignored the filter and returned unrelated results.
      if (widget.filterBody != null) {
        body.addAll(Map<String, dynamic>.from(widget.filterBody));
      }

      BlocProvider.of<ChaletsBloc>(context).add(GetAllChaletsFilterDateEvent(
        pageNumber: CommonFunctions.pageNumberFilterChalets,
        body: body,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIX: `widget.chalets` is the same mutable list instance the parent
    // reuses every rebuild (it calls .clear()/.addAll() on it in place),
    // so comparing old vs new widget by list length/identity never
    // detects a change - that's why the bottom spinner never stopped.
    // Instead, listen to the bloc directly: once a page finishes loading
    // (success or error), turn the spinner off.
    return BlocListener<ChaletsBloc, ChaletsState>(
      listener: (context, state) {
        if (_isLoadingMore &&
            (state is LoadedChaletsFilterDateState ||
                state is ErrorChaletsState)) {
          setState(() => _isLoadingMore = false);
        }
      },
      child: ListView.separated(
        controller: _scrollController,
        itemCount: widget.chalets.length,
        padding: const EdgeInsets.all(10),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final isLastItem = index == widget.chalets.length - 1;
          return _buildChaletCard(context, index, isLastItem);
        },
      ),
    );
  }

  Widget _buildChaletCard(BuildContext context, int index, bool isLastItem) {
    final chalet = widget.chalets[index];

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
          // Card Body
          Material(
            borderRadius: BorderRadius.circular(18),
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
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 124,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 104,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: BASE_URL + chalet.image,
                              fit: BoxFit.cover,
                              memCacheWidth: 220,
                              placeholder: (context, url) => Container(
                                  color: Colors.grey[100],
                                  child: const Icon(Icons.downloading, size: 30)),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: FavoriteButton(
                                item: _chaletFavoriteItem(chalet),
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(chalet.name,
                              style: TextStyles.textStyleButton(context)
                                  .copyWith(color: Colors.black)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(getTextByKey(key: TranslationKey.keyStartFrom),
                                  style: TextStyles.textStyleHelper(context)),
                              const SizedBox(width: 5),
                              Text(chalet.rentFullday,
                                  style: TextStyles.textStyleHeadline(context)
                                      .copyWith(color: yellowAppColor)),
                              const SizedBox(width: 5),
                              Text(getTextByKey(key: TranslationKey.keyOMR),
                                  style: TextStyles.textStyleTitle(context)
                                      .copyWith(color: yellowAppColor)),
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
          // Bottom loader while fetching the next page
          if (isLastItem && !widget.lastEmpty && _isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}