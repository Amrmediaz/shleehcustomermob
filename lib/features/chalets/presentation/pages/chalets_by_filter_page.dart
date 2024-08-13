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
  Widget _buildBody() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: BlocBuilder<ChaletsBloc, ChaletsState>(
          builder: (context, state) {
            if (state is LoadingChaletsState) {
              return ShimmerLoading();
            } else if (state is LoadedChaletsState) {
              if (state.page == 1) {
                chalets.clear();
              }
              chalets.addAll(state.chalets);
              return RefreshIndicator(
                  onRefresh: () => _onRefresh(context),
                  child: ChaletsByFilterPageWidget(
                    chalets: chalets,
                    chaletsStateIsEmpty: state.chalets.isEmpty,
                    filterBody : filterBody,
                    buildContext: context,
                  ));
            } else if (state is ErrorChaletsState) {
              return MessageDisplayWidget(message: state.message);
            }
            return Shimmer.fromColors(
                baseColor: Colors.grey.shade100,
                highlightColor: Colors.grey.shade200,
                child: const ShimmerLoading());
          },
          buildWhen: (previous, current) {
            if (current is LoadedChaletsState && (filterBody.containsKey("serviesList") || filterBody.containsKey("startDate"))) {
              return true;
            } else {
              return false;
            }
          },
        ));
  }

  var priceFilter = 1;
  var rateFilter = 0;
  Future<void> _onRefresh(BuildContext context) async {
    var body = {
      "page": PAGE_SIZE_CHALETS_PAGINATION,
      "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
    };
    body.addEntries(filterBody);
    BlocProvider.of<ChaletsBloc>(context).add(RefreshChaletsEvent(
        pageNumber: 1, body: body));
  }
}
