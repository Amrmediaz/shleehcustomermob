

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shleehcustomer/core/widgets/app_bar_back.dart' show AppBarBack;
import 'package:shleehcustomer/core/widgets/no_data.dart';
import 'package:shleehcustomer/features/buildings/domain/entities/building.dart';

import 'building_list_widget.dart';


class BuildingsByFilterPageWidget extends StatefulWidget {
  final List<Building> Buildings;
  final bool BuildingsStateIsEmpty;
  final dynamic filterBody;

  final BuildContext buildContext;
  BuildingsByFilterPageWidget(
      {required this.Buildings,
      required this.BuildingsStateIsEmpty,
      required this.filterBody,
      required this.buildContext});
  @override
  State<BuildingsByFilterPageWidget> createState() =>
      _BuildingsByFilterPageWidgetState();
}

class _BuildingsByFilterPageWidgetState extends State<BuildingsByFilterPageWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child:  Column(children: [
      Expanded(
          child: Container(
        padding: const EdgeInsets.all(5),
        color: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppBarBack(
              leadingWidgetAction: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            widget.Buildings.isNotEmpty ?  Expanded(
              child: BuildingByFilterListWidget(
                buildings: widget.Buildings,
                lastEmpty: widget.BuildingsStateIsEmpty ? true : false,
              ),
            ) : const NoDataWidget()
          ],
        ),
      ))
    ]));
  }
}
