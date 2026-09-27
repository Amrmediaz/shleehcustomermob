import 'dart:async'; // Required for Completer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Required for BlocConsumer / BlocProvider
import 'package:shimmer/shimmer.dart';
import 'package:shleehcustomer/core/widgets/no_data.dart';
import 'package:shleehcustomer/features/buildings/presentation/bloc/buildings/buildings_bloc.dart';

import '../../../../core/util/Constants.dart';
import '../../../../core/util/common_functions.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/building.dart';
import '../widgets/buildings_page/building_page_widget.dart'; // Required for Shimmer animation

// ── Note ─────────────────────────────────────────────────────────────────────
// Ensure your custom models, events, and widgets are imported correctly here:
// import 'path_to_building_model.dart';
// import 'path_to_buildings_bloc.dart';
// import 'path_to_common_functions.dart';
// import 'path_to_buildings_page_widget.dart';
// import 'path_to_shimmer_loading.dart';

class BuildingsPage extends StatefulWidget {
  const BuildingsPage({super.key});

  @override
  State<BuildingsPage> createState() => _BuildingsPageState();
}

class _BuildingsPageState extends State<BuildingsPage>
    with SingleTickerProviderStateMixin {
  // ── Constants ──────────────────────────────────────────────────────────────
  static const int _priceLowToHigh = 1;
  static const int _rateDefault = 0;

  // ── State ──────────────────────────────────────────────────────────────────
  final List<Building> _buildings = []; // Changed to camelCase for standard convention
  final _refreshCompleter = _RefreshCompleter();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Tracks whether the current visible list came from a filter or date query
  bool _isFilteredView = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── BLoC helpers ───────────────────────────────────────────────────────────

  /// Only re-run build() for states we care about.
  bool _shouldRebuild(BuildingsState prev, BuildingsState curr) {
    if (curr is LoadingBuildingsState) return _buildings.isEmpty;
    if (curr is LoadedBuildingsState) return true;
    if (curr is ErrorBuildingsState) return true;
    return false;
  }

  /// Side-effects only — no setState calls here.
  void _onStateChange(BuildContext context, BuildingsState state) {
    if (state is LoadedBuildingsState) {
      _isFilteredView = state.body.containsKey('serviesList') ||
          state.body.containsKey('startDate');

      // Build new list first, then do one setState.
      final updated = <Building>[];
      if (state.page > 1) updated.addAll(_buildings);
      updated.addAll(state.Buildings); // Assumed standard camelCase from your bloc state

      setState(() {
        _buildings
          ..clear()
          ..addAll(updated);
      });

      // Animate only on fresh page-1 loads.
      if (state.page == 1) {
        _fadeController
          ..reset()
          ..forward();
      }

      _refreshCompleter.complete();
    } else if (state is ErrorBuildingsState) {
      _refreshCompleter.complete();
      // FIX: only show the snackbar when we're overlaying a banner on existing
      // data. When the list is empty, _buildForState already renders the
      // full-screen error state, so showing a snackbar too was a duplicate
      // error message on screen at the same time.
      if (_buildings.isNotEmpty) {
        _showErrorSnackBar(context, state.message);
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: BlocConsumer<BuildingsBloc, BuildingsState>(
          buildWhen: _shouldRebuild,
          listener: _onStateChange,
          builder: _buildForState,
        ),
      ),
    );
  }

  Widget _buildForState(BuildContext context, BuildingsState state) {
    // Show shimmer only on initial load (list is still empty).
    if (state is LoadingBuildingsState && _buildings.isEmpty) {
      return _buildShimmer();
    }

    // Error with no cached data → full error screen.
    if (state is ErrorBuildingsState && _buildings.isEmpty) {
      return _buildErrorState(context, state.message);
    }

    // We have data (possibly with an error banner on top).
    if (_buildings.isNotEmpty) {
      final showBanner = state is ErrorBuildingsState;
      return _buildLoadedState(
          context,
          showBanner: showBanner,
          errorMessage: showBanner ? state.message : null
      );
    }

    // No data, no error yet → shown once the bloc has actually finished
    // loading with a genuinely empty result set.
    // FIX: removed the unreachable `return _buildShimmer();` that used to sit
    // after this if/else — every branch above already returns, so that line
    // could never execute.
    return Center(child: NoDataWidget(text: "لا توجد بنايات متاحة",));
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade100,
      highlightColor: Colors.grey.shade200,
      child: const ShimmerLoading(),
    );
  }

  Widget _buildLoadedState(
      BuildContext context, {
        required bool showBanner,
        String? errorMessage,
      }) {
    final content = FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        color: Theme.of(context).primaryColor,
        strokeWidth: 2.5,
        // FIX: this method is only ever called from _buildForState when
        // `_buildings.isNotEmpty`, so the `_buildEmptyState(context)` branch
        // below was dead code (unreachable). Calling BuildingsPageWidget
        // directly makes that explicit instead of hiding an unreachable path.
        child: BuildingsPageWidget(
          Buildings: _buildings,
          BuildingsStateIsEmpty: false,
          buildContext: context,
        ),
      ),
    );

    if (!showBanner) return content;

    // Overlay a warning banner without disrupting scroll.
    return Stack(
      children: [
        content,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _ErrorBanner(message: errorMessage ?? ''),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.error_outline_rounded,
                        size: 48, color: Colors.red.shade600),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'عذرًا! حدث خطأ ما',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _ActionButton(
                    label: 'إعادة المحاولة',
                    icon: Icons.refresh_rounded,
                    onTap: () => _onRefresh(context),
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    label: 'الحصول على المساعدة',
                    icon: Icons.help_outline_rounded,
                    outlined: true,
                    onTap: () => _showHelpDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on_outlined,
                        size: 56, color: Colors.blue.shade600),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'لا توجد مبانٍ متاحة',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'حاول تعديل عوامل التصفية أو تحقق مرة أخرى لاحقًا.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _ActionButton(
                    label: 'تحديث',
                    icon: Icons.refresh_rounded,
                    onTap: () => _onRefresh(context),
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    label: 'مسح عوامل التصفية',
                    icon: Icons.filter_list_off_rounded,
                    outlined: true,
                    onTap: () => _clearAndRefresh(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── الإجراءات ────────────────────────────────────────────────────────────────

  Future<void> _onRefresh(BuildContext context) {
    // FIX: previously, if the widget was unmounted, the event was skipped
    // but the completer was still reset and its Future returned — meaning
    // the RefreshIndicator's spinner would spin forever since nothing would
    // ever call _refreshCompleter.complete(). Now we bail out early with an
    // already-completed Future in that case.
    if (!mounted) return Future.value();

    CommonFunctions.pageNumberbuildings = 1;
    BlocProvider.of<BuildingsBloc>(context).add(
      RefreshBuildingsEvent(
        pageNumber: CommonFunctions.pageNumberbuildings,
        body: _defaultFilterBody(),
      ),
    );
    return _refreshCompleter.reset();
  }

  void _clearAndRefresh(BuildContext context) {
    CommonFunctions.pageNumberbuildings = 1;
    if (mounted) {
      BlocProvider.of<BuildingsBloc>(context).add(
        RefreshBuildingsEvent(
          pageNumber: CommonFunctions.pageNumberbuildings,
          body: _defaultFilterBody(),
        ),
      );
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            textColor: Colors.white,
            onPressed: () => _onRefresh(context),
          ),
        ),
      );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('هل تحتاج إلى مساعدة؟'),
        content: const Text(
          '• تأكد من اتصالك بالإنترنت\n'
              '• جرّب مسح ذاكرة التخزين المؤقت للتطبيق\n'
              '• حدّث التطبيق إلى أحدث إصدار\n'
              '• تواصل مع الدعم الفني إذا استمرت المشكلة',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _onRefresh(context);
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _defaultFilterBody() => {
    'page': 1,
    'pageSize': PAGE_SIZE_BUILDINGS_PAGINATION,
    'heightolow': _priceLowToHigh,
    'rateheightolow': _rateDefault,
  };
}

// ── أدوات مساعدة ──────────────────────────────────────────────────────────────

class _RefreshCompleter {
  Completer<void> _completer = Completer<void>()..complete();

  Future<void> reset() {
    if (!_completer.isCompleted) _completer.complete();
    _completer = Completer<void>();
    // FIX: added a timeout so the RefreshIndicator can't spin forever if the
    // bloc never emits a new Loaded/Error state after a refresh is triggered
    // (e.g. a hung request with no timeout at the network layer).
    return _completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {},
    );
  }

  void complete() {
    if (!_completer.isCompleted) _completer.complete();
  }
}

// ── عناصر واجهة صغيرة قابلة لإعادة الاستخدام ────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(bottom: BorderSide(color: Colors.orange.shade400, width: 1)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.orange.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'يتم عرض بيانات مخزّنة مؤقتًا. $message',
              style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(label),
      ],
    );

    return SizedBox(
      width: 200,
      height: 44,
      child: outlined
          ? OutlinedButton(onPressed: onTap, child: child)
          : ElevatedButton(
        onPressed: onTap,
        child: child,
      ),
    );
  }
}