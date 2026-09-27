

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/util/common_functions.dart' show CommonFunctions;
import 'package:shleehcustomer/features/buildings/domain/entities/building.dart';
import 'package:shleehcustomer/features/buildings/presentation/bloc/Buildings/buildings_bloc.dart';
import 'package:shleehcustomer/features/buildings/presentation/widgets/buildings_page/building_card.dart' show buildBuildingCard;

class BuildingByFilterListWidget extends StatelessWidget {
  final List<Building> buildings;
  final bool lastEmpty;

  const BuildingByFilterListWidget({
    Key? key,
    required this.buildings,
    required this.lastEmpty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: buildings.length,
      padding: const EdgeInsets.all(10),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        bool isLastItem = index == buildings.length - 1;

        // Pagination Trigger
        if (isLastItem && !lastEmpty) {
          CommonFunctions.pageNumberFilterBuildings++;
          BlocProvider.of<BuildingsBloc>(context).add(GetAllBuildingsEvent(
              pageNumber: CommonFunctions.pageNumberFilterBuildings,
              body: {
                "page": CommonFunctions.pageNumberFilterBuildings,
                "pageSize": PAGE_SIZE_BUILDINGS_PAGINATION,
                "heightolow": 1,
                "rateheightolow": 0
              }));
        }

        return buildBuildingCard(context,index, buildings[index],isLastItem,lastEmpty);
      },
    );
  }


}