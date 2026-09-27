import 'package:flutter/material.dart';
import 'package:shleehcustomer/features/buildings/presentation/widgets/filter_page/filter_dates_widget.dart';
import 'package:shleehcustomer/features/buildings/presentation/widgets/filter_page/filter_widget.dart';



class BuildingFilterPage extends StatelessWidget {
final String filterType;
  const BuildingFilterPage({
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
