import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/widgets/message_display_widget.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../bloc/buildings/buildings_bloc.dart';
import '../bloc/flat/flats_bloc.dart';
import '../widgets/building_detail_page/building_detail_widget.dart';

class BuildingDetailPage extends StatelessWidget {
  final String? buildingId;

  const BuildingDetailPage({
    Key? key,
    this.buildingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  appBar: _buildAppbar(),
      body: SafeArea(top: false,child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<BuildingsBloc, BuildingsState>(
      builder: (context, state) {
        if (state is LoadedBuildingIdState) {
          BlocProvider.of<FlatsBloc>(context)
              .add( GetFlatByBuildingIdEvent(
            body: {
              "page": 1,
              "pageSize": 20,
              "buildingId":  state.buildingDetails.id,
            },
          ));
          return Padding(
            padding: const EdgeInsets.all(0),
            child: BuildingDetailWidget(building: state.buildingDetails,),
          );
        } else if (state is LoadingBuildingIdState) {
          return const LoadingWidget();
        } else {
          return MessageDisplayWidget(
            message: getTextByKey(key: TranslationKey.keyError),
            onRetry: buildingId == null
                ? null
                : () => context.read<BuildingsBloc>().add(LoadBuildingsById(id: buildingId!)),
          );
        }
      },
      // Was missing ErrorBuildingsIdState here — same stuck-spinner-forever
      // bug already fixed on the chalet and booking detail pages: buildWhen
      // only let Loaded/Loading through, so a failed fetch left the user
      // staring at a permanent spinner instead of an error + retry.
      buildWhen: (previous, current) =>
          (current is LoadedBuildingIdState) ||
          (current is LoadingBuildingIdState) ||
          (current is ErrorBuildingsIdState),
    );
  }
}
