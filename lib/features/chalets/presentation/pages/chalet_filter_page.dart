import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/strings/language.dart';
import 'package:shleehcustomer/core/widgets/message_display_widget.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/chalet_detail_page/chalet_detail_widget.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/filter_page/filter_dates_widget.dart';
import 'package:shleehcustomer/features/chalets/presentation/widgets/filter_page/filter_widget.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/chalet.dart';
import '../bloc/chalets/chalets_bloc.dart';

class ChaletFilterPage extends StatelessWidget {
final String filterType;
  const ChaletFilterPage({
    Key? key,
    required this.filterType

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  appBar: _buildAppbar(),
      body: SafeArea(top: false,child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return  filterType == "date" ? FilterDateWidget() : FilterWidget();
  }
}
