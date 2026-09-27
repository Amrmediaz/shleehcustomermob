import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shleehcustomer/features/buildings/presentation/widgets/map/building_map_widget.dart';

import '../../../../core/strings/assets_path.dart';
import '../../../../core/strings/language.dart';
import '../../../../core/util/common_functions.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/message_display_widget.dart';
import '../bloc/buildings/buildings_bloc.dart';

class BuildingsMapScreen extends StatelessWidget {
  BuildingsMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    return BlocBuilder<BuildingsBloc, BuildingsState>(
      builder: (context, state) {
        if (state is LoadedBuildingsMapState) {
          return Padding(
            padding: EdgeInsets.all(0),
            child: BuildingMapWidget(
              Buildings: state.Buildings,
            ),
          );
        } else if (state is LoadingBuildingsMapState) {
          return const LoadingWidget();
        } else if (state is ErrorBuildingsMapState) {
          return MessageDisplayWidget(
            message: state.message,
            onRetry: () => context.read<BuildingsBloc>().add(GetAllBuildingsMapEvent()),
          );
        } else {
          return Container();
        }
      },
      // Was missing ErrorBuildingsMapState here — same stuck-spinner-forever
      // bug as the detail pages: a failed map fetch never rebuilt past the
      // loading spinner since buildWhen only allowed Loaded/Loading through.
      buildWhen: (previous, current) =>
          (current is LoadedBuildingsMapState) ||
          (current is LoadingBuildingsMapState) ||
          (current is ErrorBuildingsMapState),
    );
  }
}
