import 'package:shimmer/shimmer.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building.dart';
import 'package:shleehcustomer/features/buildings/presentation/bloc/buildings/buildings_bloc.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/core/widgets/message_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/widgets/shimmer_loading.dart';

// ✅ FIXED: Explicit lowercase paths matching package definitions exactly
import 'package:shleehcustomer/features/buildings/presentation/widgets/buildings_page/building_page_widget.dart';
import 'package:shleehcustomer/features/buildings/presentation/widgets/filter_page/buildings_by_filter_page//building_page_widget.dart';

class BuildingsByFilterPage extends StatelessWidget {
  final dynamic filterBody;
  BuildingsByFilterPage({super.key, required this.filterBody});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  final List<Building> Buildings = [];

  Widget _buildBody() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: BlocBuilder<BuildingsBloc, BuildingsState>(
          builder: (context, state) {
            if (state is LoadingBuildingsState) {
              return ShimmerLoading();
            } else if (state is LoadedBuildingsState) {
              if (state.page == 1) {
                Buildings.clear();
              }
              Buildings.addAll(state.Buildings);
              return RefreshIndicator(
                  onRefresh: () => _onRefresh(context),
                  child: BuildingsByFilterPageWidget(
                    Buildings: Buildings,
                    BuildingsStateIsEmpty: state.Buildings.isEmpty,
                    filterBody : filterBody,
                    buildContext: context,
                  ));
            } else if (state is ErrorBuildingsState) {
              return MessageDisplayWidget(message: state.message);
            }
            return Shimmer.fromColors(
                baseColor: Colors.grey.shade100,
                highlightColor: Colors.grey.shade200,
                child: const ShimmerLoading());
          },
          // FIX: previously only returned true for LoadedBuildingsState when
          // filterBody happened to contain "serviesList"/"startDate" keys —
          // every other case (including all Loading/Error states, and Loaded
          // states for other filter combos) returned false, so this
          // BlocBuilder would never rebuild and the user was stuck on the
          // fallback shimmer forever. Same stuck-forever bug already fixed
          // on the chalets filter page; mirrored here.
          buildWhen: (previous, current) {
            return current is LoadingBuildingsState ||
                current is LoadedBuildingsState ||
                current is ErrorBuildingsState;
          },
        ));
  }

  var priceFilter = 1;
  var rateFilter = 0;
  Future<void> _onRefresh(BuildContext context) async {
    var body = {
      "page": 1,
      "pageSize": PAGE_SIZE_BUILDINGS_PAGINATION,
    };
    body.addEntries(filterBody);
    BlocProvider.of<BuildingsBloc>(context).add(RefreshBuildingsEvent(
        pageNumber: 1, body: body));
  }
}