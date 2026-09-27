import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shleehcustomer/core/util/Constants.dart';
import 'package:shleehcustomer/features/chalets/domain/entities/chalet.dart';
import 'package:shleehcustomer/features/chalets/presentation/bloc/chalets/chalets_bloc.dart';
import '../../../../core/util/common_functions.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../widgets/chalets_page/chalet_page_widget.dart';

class ChaletsPage extends StatefulWidget {
  const ChaletsPage({super.key});

  @override
  State<ChaletsPage> createState() => _ChaletsPageState();
}

class _ChaletsPageState extends State<ChaletsPage>
    with SingleTickerProviderStateMixin {
  // ── Constants ──────────────────────────────────────────────────────────────
  static const int _priceLowToHigh = 1;
  static const int _rateDefault = 0;

  // ── State ──────────────────────────────────────────────────────────────────
  final List<Chalet> _chalets = [];
  final _refreshCompleter = _RefreshCompleter();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Tracks whether the current visible list came from a filter or date query
  // so we know not to merge results incorrectly.
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
  bool _shouldRebuild(ChaletsState prev, ChaletsState curr) {
    if (curr is LoadingChaletsState) return _chalets.isEmpty;
    if (curr is LoadedChaletsState) return true;
    if (curr is ErrorChaletsState) return true;
    return false;
  }

  /// Side-effects only — no setState calls here.
  void _onStateChange(BuildContext context, ChaletsState state) {
    if (state is LoadedChaletsState) {
      _isFilteredView = state.body.containsKey('serviesList') ||
          state.body.containsKey('startDate');

      // Build new list first, then do one setState.
      final updated = <Chalet>[];
      if (state.page > 1) updated.addAll(_chalets);
      updated.addAll(state.chalets);

      setState(() => _chalets
        ..clear()
        ..addAll(updated));

      // Animate only on fresh page-1 loads.
      if (state.page == 1) {
        _fadeController
          ..reset()
          ..forward();
      }

      _refreshCompleter.complete();
    } else if (state is ErrorChaletsState) {
      _refreshCompleter.complete();
      _showErrorSnackBar(context, state.message);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // No outer Padding here anymore — it used to inset the whole tab
    // (including the purple hero header from ChaletsPageWidget) by 10px on
    // each side and 8px on top, which made that hero band look like a
    // separate, narrower, gapped-off block sitting under the home page's
    // full-width purple logo bar instead of one continuous purple header.
    // The list and empty/error states below already carry their own
    // padding (ChaletListWidget's ListView, the centered error/empty
    // layouts), so nothing relies on this outer padding anymore.
    return Scaffold(
      body: BlocConsumer<ChaletsBloc, ChaletsState>(
        buildWhen: _shouldRebuild,
        listener: _onStateChange,
        builder: _buildForState,
      ),
    );
  }

  Widget _buildForState(BuildContext context, ChaletsState state) {
    // Show shimmer only on initial load (list is still empty).
    if (state is LoadingChaletsState && _chalets.isEmpty) {
      return _buildShimmer();
    }

    // Error with no cached data → full error screen.
    if (state is ErrorChaletsState && _chalets.isEmpty) {
      return _buildErrorState(context, state.message);
    }

    // We have data (possibly with an error banner on top).
    if (_chalets.isNotEmpty) {
      final showBanner = state is ErrorChaletsState;
      return _buildLoadedState(context, showBanner: showBanner,
          errorMessage: showBanner ? (state as ErrorChaletsState).message : null);
    }

    // No data, no error yet → shimmer as safe fallback.
    return _buildShimmer();
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
        child: _chalets.isEmpty
            ? _buildEmptyState(context)
            : ChaletsPageWidget(
          chalets: _chalets,
          // Empty → last page already reached.
          chaletsStateIsEmpty: false,
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
                    'Oops! Something went wrong',
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
                    label: 'Try Again',
                    icon: Icons.refresh_rounded,
                    onTap: () => _onRefresh(context),
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    label: 'Get Help',
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
                    'No Chalets Available',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Try adjusting your filters or check back later.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _ActionButton(
                    label: 'Refresh',
                    icon: Icons.refresh_rounded,
                    onTap: () => _onRefresh(context),
                  ),
                  const SizedBox(height: 12),
                  _ActionButton(
                    label: 'Clear Filters',
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

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _onRefresh(BuildContext context) {
    CommonFunctions.pageNumberChalets = 1;
    if (mounted) {
      BlocProvider.of<ChaletsBloc>(context).add(
        RefreshChaletsEvent(
          pageNumber: CommonFunctions.pageNumberChalets,
          body: _defaultFilterBody(),
        ),
      );
    }
    // Return a future that completes when the state update arrives.
    return _refreshCompleter.reset();
  }

  void _clearAndRefresh(BuildContext context) {
    CommonFunctions.pageNumberChalets = 1;
    if (mounted) {
      BlocProvider.of<ChaletsBloc>(context).add(
        RefreshChaletsEvent(
          pageNumber: CommonFunctions.pageNumberChalets,
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
            label: 'Retry',
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
        title: const Text('Need Help?'),
        content: const Text(
          '• Check your internet connection\n'
              '• Try clearing app cache\n'
              '• Update to the latest version\n'
              '• Contact support if the issue persists',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _onRefresh(context);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _defaultFilterBody() => {
    'page': 1,
    'pageSize': PAGE_SIZE_CHALETS_PAGINATION,
    'heightolow': _priceLowToHigh,
    'rateheightolow': _rateDefault,
  };
}

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Lets us hand a Future back to RefreshIndicator that only resolves
/// once the BLoC actually emits a result (success or error).
class _RefreshCompleter {
  Completer<void> _completer = Completer<void>()..complete();

  Future<void> reset() {
    if (!_completer.isCompleted) _completer.complete();
    _completer = Completer<void>();
    return _completer.future;
  }

  void complete() {
    if (!_completer.isCompleted) _completer.complete();
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border:
        Border(bottom: BorderSide(color: Colors.orange.shade400, width: 1)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.orange.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing cached data. $message',
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