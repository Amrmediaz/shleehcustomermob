import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../favorites/favorite_item.dart';
import '../favorites/favorites_cubit.dart';
import '../strings/language.dart';

/// A small circular heart button meant to sit as an overlay on a card's
/// photo (top corner), same visual slot already used for the rating/
/// location badges on the chalet and building cards. Tapping it toggles the
/// item in/out of FavoritesCubit's list (persisted locally, no backend
/// needed) and gives a quick "pop" so the action feels acknowledged.
class FavoriteButton extends StatefulWidget {
  final FavoriteItem item;
  final double size;

  const FavoriteButton({
    Key? key,
    required this.item,
    this.size = 17,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _bounce = false;

  Future<void> _handleTap(BuildContext context) async {
    final cubit = context.read<FavoritesCubit>();
    setState(() => _bounce = true);
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _bounce = false);
    });

    final ok = await cubit.toggle(widget.item);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(TranslationKey.keyFavoritesLimitReached)),
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (previous, current) =>
          previous.isFavorite(widget.item.key) !=
          current.isFavorite(widget.item.key),
      builder: (context, state) {
        final isFavorite = state.isFavorite(widget.item.key);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleTap(context),
          child: AnimatedScale(
            scale: _bounce ? 1.28 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: widget.size,
                color: isFavorite ? const Color(0xFFE53E5E) : const Color(0xFF3C4043),
              ),
            ),
          ),
        );
      },
    );
  }
}
