import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/map/chalet_map_widget.dart';

import '../../../../core/strings/assets_path.dart';
import '../../../../core/util/common_functions.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/chalets/chalets_bloc.dart';

class ChaletsMapScreen extends StatelessWidget {
  ChaletsMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    return BlocBuilder<ChaletsBloc, ChaletsState>(
      builder: (context, state) {
        if (state is LoadedChaletsMapState) {
          return Padding(
            padding: EdgeInsets.all(0),
            child: ChaletMapWidget(
              chalets: state.chalets,
            ),
          );
        } else if (state is LoadingChaletsMapState) {
          return const LoadingWidget();
        } else {
          return Container();
        }
      },
      buildWhen: (previous, current) =>
          (current is LoadedChaletsMapState) ||
          (current is LoadingChaletsMapState),
    );
  }
}
