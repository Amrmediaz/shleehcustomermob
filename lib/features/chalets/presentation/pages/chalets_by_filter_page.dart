import 'package:shimmer/shimmer.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import '../../../../core/util/common_functions.dart';
import '../../../../core/widgets/message_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../widgets/chalets_page/chalet_page_widget.dart';
import '../widgets/filter_page/chalets_by_filter_page/chalet_page_widget.dart';

// ---------------------------------------------------------------------------
// UPDATED: this page was piggybacking on LoadingFilterDateChaletsState /
// LoadedChaletsFilterDateState / ErrorChaletsState + RefreshChaletsEvent —
// those belong to the date-only filter flow (GetAllChaletsFilterDateEvent),
// which is a different bloc branch. Now that chalets_bloc.dart has its own
// dedicated Filter* states/events (GetAllChaletsFilterEvent /
// LoadMoreChaletsFilterEvent / RefreshChaletsFilterEvent ->
// LoadingChaletsFilterState / LoadedChaletsFilterState /
// ErrorChaletsFilterState), this page is switched over to those so its
// pagination/refresh can no longer collide with the date-search flow or
// the home feed.
//
// NOTE: I don't have '../widgets/filter_page/chalets_by_filter_page/
// chalet_page_widget.dart' (ChaletsByFilterPageWidget). If it dispatches
// LoadMoreChaletsEvent internally for infinite scroll, switch that to
// LoadMoreChaletsFilterEvent too, so every step of this page's pagination
// stays on the Filter* states.
// ---------------------------------------------------------------------------

class ChaletsByFilterPage extends StatelessWidget {
  final dynamic filterBody;

  ChaletsByFilterPage({super.key, required this.filterBody});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  List<Chalet> chalets = [];
  bool _lastChaletsEmpty = false;

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: BlocBuilder<ChaletsBloc, ChaletsState>(
        builder: (context, state) {
          if (state is LoadingChaletsFilterState) {
            // FIX: this state fires for pagination fetches too, not just
            // the first load. If we already have items on screen, keep
            // showing them (the list widget shows its own small bottom
            // loader) instead of tearing down the whole ListView - that
            // was disposing the ScrollController and resetting scroll
            // to the top every time you scrolled to the bottom.
            if (chalets.isEmpty) {
              return ShimmerLoading();
            }
            return RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              child: ChaletsByFilterPageWidget(
                chalets: chalets,
                chaletsStateIsEmpty: _lastChaletsEmpty,
                filterBody: filterBody,
                buildContext: context,
              ),
            );
          } else if (state is LoadedChaletsFilterState) {
            if (state.page == 1) {
              chalets.clear();
            }
            chalets.addAll(state.chalets);
            _lastChaletsEmpty = state.chalets.isEmpty;
            return RefreshIndicator(
              onRefresh: () => _onRefresh(context),
              child: ChaletsByFilterPageWidget(
                chalets: chalets,
                chaletsStateIsEmpty: _lastChaletsEmpty,
                filterBody: filterBody,
                buildContext: context,
              ),
            );
          } else if (state is ErrorChaletsFilterState) {
            return MessageDisplayWidget(message: state.message);
          }
          return Center(child: Text(state.toString()));
        },
        // FIX: previously this returned `false` for
        // LoadingFilterDateChaletsState / ErrorChaletsState, so the
        // shimmer/error UI never rendered - only Loaded states ever
        // got through. Now every state relevant to this page rebuilds it.
        buildWhen: (previous, current) {
          if (current is LoadingChaletsFilterState ||
              current is ErrorChaletsFilterState) {
            return true;
          }
          if (current is LoadedChaletsFilterState) {
            return true;
          }
          return false;
        },
      ),
    );
  }

  var priceFilter = 1;
  var rateFilter = 0;

  Future<void> _onRefresh(BuildContext context) async {
    var body = {
      "page": 1,
      "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
    };
    body.addEntries(filterBody.entries);
    CommonFunctions.pageNumberFillterChalets = 1;
    BlocProvider.of<ChaletsBloc>(context)
        .add(RefreshChaletsFilterEvent(pageNumber: 1, body: body));
  }
}