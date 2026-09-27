import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/styles/text/text_style.dart';
import 'package:shleehcustomer/core/widgets/no_data.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalet_filter_page.dart';
import 'package:shleehcustomer/features/chalets/presentation/pages/chalets_map_screen.dart';

import '../../../../../../core/strings/assets_path.dart';
import '../../../../../../core/strings/language.dart';
import '../../../../../../core/util/Constants.dart';
import '../../../../../../core/util/common_functions.dart';
import '../../../../../../core/widgets/app_bar_back.dart';
import '../../../../../../core/widgets/text_icon.dart';
import '../../../../domain/entities/chalet.dart';
import 'chalet_list_widget.dart';

class ChaletsByFilterPageWidget extends StatefulWidget {
  final List<Chalet> chalets;
  final bool chaletsStateIsEmpty;
  final dynamic filterBody;
  final BuildContext buildContext;

  ChaletsByFilterPageWidget({
    required this.chalets,
    required this.chaletsStateIsEmpty,
    required this.filterBody,
    required this.buildContext,
  });

  @override
  State<ChaletsByFilterPageWidget> createState() =>
      _ChaletsByFilterPageWidgetState();
}

class _ChaletsByFilterPageWidgetState
    extends State<ChaletsByFilterPageWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
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
                  widget.chalets.isNotEmpty
                      ? Expanded(
                    child: ChaletByFilterListWidget(
                      chalets: widget.chalets,
                      lastEmpty: widget.chaletsStateIsEmpty,
                      // FIX: the active date/service filter now
                      // flows down into the list so pagination
                      // requests can include it.
                      filterBody: widget.filterBody,
                    ),
                  )
                      : const NoDataWidget()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}