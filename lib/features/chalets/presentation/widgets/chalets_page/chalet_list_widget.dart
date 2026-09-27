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
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/home_page/presentation/bloc/home/home_bloc.dart';
import '../../../../../core/styles/app_theme.dart' as AppTheme;
import '../../pages/chalet_detail_page.dart';
import '../../../domain/entities/chalet.dart';
import 'chalet_card.dart';

class ChaletListWidget extends StatefulWidget {
  final List<Chalet> chalets;
  final bool lastEmpty;

  const ChaletListWidget({
    Key? key,
    required this.chalets,
    required this.lastEmpty,
  }) : super(key: key);

  @override
  State<ChaletListWidget> createState() => _ChaletListWidgetState();
}

class _ChaletListWidgetState extends State<ChaletListWidget> {
  bool _isLoadingMore = false;
  Set<int> _favoriteIds = {};

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChaletsBloc, ChaletsState>(
      listener: (context, state) {
        // Reset the flag when Bloc finishes loading
        if (state is LoadedChaletsState || state is ErrorChaletsState) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      },
      child: ListView.separated(
        // ✅ Add 1 item for loading footer only when loading AND not last page
        itemCount: widget.chalets.length + (_isLoadingMore && !widget.lastEmpty ? 1 : 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemBuilder: (context, index) {
          // Show loading indicator as last item
          if (index == widget.chalets.length) {
            return _buildLoadingFooter();
          }

          bool isLastItem = index == widget.chalets.length - 1;

          // ✅ Trigger pagination when reaching last item (if there's more data)
          // Deferred to after this frame via addPostFrameCallback: dispatching
          // a Bloc event (and mutating _isLoadingMore) synchronously from inside
          // itemBuilder — i.e. during build() — can change this ListView's item
          // count while Flutter is still building/laying out/computing semantics
          // for the current frame's viewport. That's exactly the kind of
          // mid-frame viewport mutation that can crash deep inside
          // RenderViewportBase.visitChildrenForSemantics with a null-check error
          // during fast scrolling. Doing it post-frame lets the current frame
          // finish cleanly before anything changes the list.
          if (isLastItem && !widget.lastEmpty && !_isLoadingMore) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _isLoadingMore) return;

              setState(() {
                _isLoadingMore = true;
              });

              CommonFunctions.pageNumberChalets = CommonFunctions.pageNumberChalets + 1;

              BlocProvider.of<ChaletsBloc>(context).add(
                LoadMoreChaletsEvent(
                  pageNumber: CommonFunctions.pageNumberChalets,
                  body: {
                    "page": CommonFunctions.pageNumberChalets,
                    "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
                    "heightolow": 1,
                    "rateheightolow": 0
                  },
                ),
              );
            });
          }

          return buildChaletCard(
            context,
            index,
            widget.chalets[index],
            isLastItem,
            widget.lastEmpty,
          );
        },
        separatorBuilder: (context, index) {
          // No separator before loading footer
          if (index == widget.chalets.length) {
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