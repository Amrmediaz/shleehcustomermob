import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/network/urls.dart';
import 'package:shleehcustomer/core/strings/assets_path.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/util/common_functions.dart';
import 'package:shleehcustomer/core/widgets/loading_image.dart';
import 'package:shleehcustomer/features/buildings/presentation/bloc/buildings/buildings_bloc.dart';
import 'package:shleehcustomer/features/home_page/presentation/bloc/home/home_bloc.dart';
import '../../../../../core/styles/app_theme.dart' as AppTheme;
import '../../pages/building_detail_page.dart';
import '../../../domain/entities/building.dart';
import 'building_card.dart';

class BuildingListWidget extends StatefulWidget {
  final List<Building> buildings;
  final bool lastEmpty;

  const BuildingListWidget({
    Key? key,
    required this.buildings,
    required this.lastEmpty,
  }) : super(key: key);

  @override
  State<BuildingListWidget> createState() => _BuildingListWidgetState();
}

class _BuildingListWidgetState extends State<BuildingListWidget> {
  bool _isLoadingMore = false;
  Set<int> _favoriteIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocListener<BuildingsBloc, BuildingsState>(
      listener: (context, state) {
        // Reset the flag when Bloc finishes loading
        if (state is LoadedBuildingsState || state is ErrorBuildingsState) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      },
      child: ListView.separated(
        // ✅ Add 1 item for loading footer only when loading AND not last page
        itemCount: widget.buildings.length + (_isLoadingMore && !widget.lastEmpty ? 1 : 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemBuilder: (context, index) {
          // Show loading indicator as last item
          if (index == widget.buildings.length) {
            return _buildLoadingFooter();
          }

          bool isLastItem = index == widget.buildings.length - 1;

          // ✅ Trigger pagination when reaching last item (if there's more data)
          // Deferred to after this frame — see matching comment in
          // chalet_list_widget.dart for why dispatching the Bloc event
          // synchronously during build() is unsafe here.
          if (isLastItem && !widget.lastEmpty && !_isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _isLoadingMore) return;

              setState(() {
                _isLoadingMore = true;
              });

              CommonFunctions.pageNumberbuildings = CommonFunctions.pageNumberbuildings + 1;

              BlocProvider.of<BuildingsBloc>(context).add(
                LoadMoreBuildingsEvent(
                  pageNumber: CommonFunctions.pageNumberbuildings,
                  body: {
                    "page": CommonFunctions.pageNumberbuildings,
                    "pageSize": PAGE_SIZE_BUILDINGS_PAGINATION,
                    "heightolow": 1,
                    "rateheightolow": 0
                  },
                ),
              );
            });
          }

          return buildBuildingCard(
            context,
            index,
            widget.buildings[index],
            isLastItem,
            widget.lastEmpty,
          );
        },
        separatorBuilder: (context, index) {
          // No separator before loading footer
          if (index == widget.buildings.length) {
            return const SizedBox.shrink();
          }
          return const SizedBox(height: 12);
        },
      ),
    );
  }

  /// Loading footer - only shown when actively loading more items
  Widget _buildLoadingFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}