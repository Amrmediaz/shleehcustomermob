// Updated to match your latest BookingsBloc: GetAllBookingsEvent /
// GetAllBookingsEventFlat no longer take an `isChalet` param (the bloc
// hardcodes it per event type), so this picks the right event constructor
// based on `widget.isChalet` instead of passing a flag into one event.
//
// Tab bar redesigned as a rounded pill/segmented switcher instead of the
// plain underline TabBar — should look a lot more polished.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shleehcustomer/core/styles/app_theme.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/core/widgets/no_data.dart';
import 'package:shleehcustomer/features/booking/domain/entities/booking.dart';
import 'package:shleehcustomer/features/booking/presentation/bloc/bookings/bookings_bloc.dart';
import 'package:shleehcustomer/features/booking/presentation/pages/payment_bank_screen_web_view.dart';
import '../../../../core/util/common_functions.dart';
import '../../../../core/widgets/message_display_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../widgets/user_bookings/booking_page_widget.dart';

class UserBookingPage extends StatefulWidget {
  const UserBookingPage({super.key});

  @override
  State<UserBookingPage> createState() => _UserBookingPageState();
}

class _UserBookingPageState extends State<UserBookingPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: Column(
          children: [
            _BookingTypeSwitcher(controller: _tabController),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _BookingsTabBody(isChalet: true),
                  _BookingsTabBody(isChalet: false),
                ],
              ),
            ),
          ],
        ),

    );
  }
}

/// Rounded pill/segmented-control style tab switcher — replaces the plain
/// underline TabBar with something closer to an iOS-style segmented control.
class _BookingTypeSwitcher extends StatelessWidget {
  final TabController controller;
  const _BookingTypeSwitcher({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: controller,
        splashBorderRadius: BorderRadius.circular(26),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(vertical: 2),
        indicator: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        tabs: const [
          Tab(
            height: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.holiday_village_rounded, size: 17),
                SizedBox(width: 6),
                Text('الشاليهات'),
              ],
            ),
          ),
          Tab(
            height: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apartment_rounded, size: 17),
                SizedBox(width: 6),
                Text('الشقق'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingsTabBody extends StatefulWidget {
  final bool isChalet;
  const _BookingsTabBody({required this.isChalet});

  @override
  State<_BookingsTabBody> createState() => _BookingsTabBodyState();
}

class _BookingsTabBodyState extends State<_BookingsTabBody>
    with AutomaticKeepAliveClientMixin {
  final List<Booking> _bookings = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  bool get wantKeepAlive => true;

  BookingsEvent _fetchEvent(int pageNumber) {
    return widget.isChalet
        ? GetAllBookingsEvent(pageNumber: pageNumber, pageSize: PAGE_SIZE_CHALETS_PAGINATION)
        : GetAllBookingsEventFlat(pageNumber: pageNumber, pageSize: PAGE_SIZE_CHALETS_PAGINATION);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BookingsBloc>().add(_fetchEvent(1));
    });
  }

  void _loadMore() {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    context.read<BookingsBloc>().add(_fetchEvent(_currentPage + 1));
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    context.read<BookingsBloc>().add(_fetchEvent(1));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: BlocBuilder<BookingsBloc, BookingState>(
        buildWhen: (previous, current) {
          final matchesTab = widget.isChalet
              ? (current is LoadingBookingsState ||
              current is LoadedBookingsState ||
              current is ErrorBookingsState)
              : (current is LoadingBookingsStateFlat ||
              current is LoadedBookingsStateFlat ||
              current is ErrorBookingsStateFlat);
          if (!matchesTab) return false;

          // Only the very first fetch shows the full-page shimmer; a
          // load-more Loading state is ignored — the footer spinner in
          // BookingListWidget covers that case instead.
          final isLoadingState = widget.isChalet
              ? current is LoadingBookingsState
              : current is LoadingBookingsStateFlat;
          if (isLoadingState && _bookings.isNotEmpty) return false;

          return true;
        },
        builder: (context, state) {
          final isLoading = widget.isChalet
              ? state is LoadingBookingsState
              : state is LoadingBookingsStateFlat;
          if (isLoading) return const ShimmerLoading();

          final errorMessage = widget.isChalet
              ? (state is ErrorBookingsState ? state.message : null)
              : (state is ErrorBookingsStateFlat ? state.message : null);
          if (errorMessage != null) return MessageDisplayWidget(message: errorMessage);

          final int? page = widget.isChalet
              ? (state is LoadedBookingsState ? state.page : null)
              : (state is LoadedBookingsStateFlat ? state.page : null);
          final List<Booking>? newBookings = widget.isChalet
              ? (state is LoadedBookingsState ? state.bookings : null)
              : (state is LoadedBookingsStateFlat ? state.bookings : null);
          final bool? hasMore = widget.isChalet
              ? (state is LoadedBookingsState ? state.hasMore : null)
              : (state is LoadedBookingsStateFlat ? state.hasMore : null);

          if (newBookings != null && page != null && hasMore != null) {
            if (page == 1) {
              _bookings
                ..clear()
                ..addAll(newBookings);
            } else if (page > _currentPage) {
              // Guards against a stray duplicate emission re-appending
              // a page we already have.
              _bookings.addAll(newBookings);
            }
            _currentPage = page;
            _hasMore = hasMore;
            _isLoadingMore = false;

            return _bookings.isEmpty
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [NoDataWidget()],
            )
                : RefreshIndicator(
              onRefresh: _onRefresh,
              child: BookingsPageWidget(
                bookings: _bookings,
                hasMore: _hasMore,
                isLoadingMore: _isLoadingMore,
                onLoadMore: _loadMore,
                isChalet: widget.isChalet,
              ),
            );
          }

          return const ShimmerLoading();
        },
      ),
    );
  }
}