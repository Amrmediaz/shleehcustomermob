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

class ChaletsPage extends StatelessWidget {
  ChaletsPage({super.key});

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
              return const ShimmerLoading();
            } else if (state is LoadedChaletsState) {
              print(CommonFunctions.pageNumberChalets);
              if (state.page == 1) {
                chalets.clear();
              }
              chalets.addAll(state.chalets);
              return RefreshIndicator(
                  onRefresh: () => _onRefresh(context),
                  child: ChaletsPageWidget(
                    chalets: chalets,
                    chaletsStateIsEmpty: state.chalets.isEmpty,
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
            if (current is LoadedChaletsState &&
                (!current.body.containsKey("serviesList") &&
                    (!current.body.containsKey("startDate")))) {
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
    CommonFunctions.pageNumberChalets = 1;

    BlocProvider.of<ChaletsBloc>(context).add(RefreshChaletsEvent(
        pageNumber: CommonFunctions.pageNumberChalets,
        body: {
          "page":1,
          "pageSize": PAGE_SIZE_CHALETS_PAGINATION,
          "heightolow": 1,
          "rateheightolow": 0
        }));
  }
}
