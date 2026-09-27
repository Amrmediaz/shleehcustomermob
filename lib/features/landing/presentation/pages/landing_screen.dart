
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/message_display_widget.dart';
import '../../../home_page/presentation/widgets/on_board_pager.dart';
import '../bloc/landing/landing_bloc.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SafeArea(child: Padding(
      padding: const EdgeInsets.all(10),
      child: BlocBuilder<LandingBloc, LandingState>(
        builder: (context, state) {
          if (state is LoadingLandingState) {
            return LoadingWidget();
          } else if (state is LoadedOnboardState) {
            return OnBoardPageWidget(onboards: state.onboards,);
          } else if (state is ErrorLandingState) {
            return MessageDisplayWidget(
              message: state.message,
              onRetry: () => context.read<LandingBloc>().add(LandingEventObj()),
            );
          }
          return LoadingWidget();
        },
      ),
    ));
  }



}
