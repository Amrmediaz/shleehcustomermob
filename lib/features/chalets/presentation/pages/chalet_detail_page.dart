import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/widgets/message_display_widget.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/chalet_detail_page/chalet_detail_widget.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/chalet.dart';
import '../bloc/chalets/chalets_bloc.dart';

class ChaletDetailPage extends StatelessWidget {
  final String? chaletId;

  const ChaletDetailPage({
    Key? key,
    this.chaletId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  appBar: _buildAppbar(),
      body: SafeArea(top: false,child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ChaletsBloc, ChaletsState>(
      builder: (context, state) {
        if (state is LoadedChaletIdState) {
          return Padding(
            padding: const EdgeInsets.all(0),
            child:SafeArea(top: false,child:  ChaletDetailWidget(chalet: state.chalet)),
          );
        } else if (state is LoadingChaletIdState) {
          return const LoadingWidget();
        } else {
          return MessageDisplayWidget(
            message: getTextByKey(key: TranslationKey.keyError),
            onRetry: chaletId == null
                ? null
                : () => context.read<ChaletsBloc>().add(LoadChaletsById(id: chaletId!)),
          );
        }
      },
      // Was missing ErrorChaletsIdState here — meant that if loading the
      // chalet failed *after* this page was already on screen, the
      // BlocBuilder would never rebuild past the loading spinner (buildWhen
      // only allowed Loaded/Loading through), leaving the user stuck on a
      // permanent spinner instead of ever seeing the error above.
      buildWhen: (previous, current) =>
          (current is LoadedChaletIdState) ||
          (current is LoadingChaletIdState) ||
          (current is ErrorChaletsIdState),
    );
  }
}
