import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/env.dart';
import '../models/animal.dart';
import '../theme/app_theme.dart';
import 'shimmer_loading.dart';

class AnimalThumbnail extends StatefulWidget {
  final Animal animal;
  final int index;
  final bool guessed;
  final VoidCallback onTap;

  const AnimalThumbnail({
    super.key,
    required this.animal,
    required this.index,
    required this.guessed,
    required this.onTap,
  });

  @override
  State<AnimalThumbnail> createState() => _AnimalThumbnailState();
}

class _AnimalThumbnailState extends State<AnimalThumbnail> {
  bool _pressed = false;

  String? _resolveUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('http')) return url;
    return '${Env.originUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveUrl(widget.animal.imageUrl);
    final hasImage = resolvedUrl != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.guessed
                    ? AppColors.correctGreen.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                // Image area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: widget.guessed
                          ? AppColors.correctGreen.withValues(alpha: 0.06)
                          : AppColors.deepPurple.withValues(alpha: 0.05),
                    ),
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: resolvedUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                _skeletonLoader(widget.guessed),
                            errorWidget: (context, url, error) =>
                                _emojiPlaceholder(widget.guessed),
                          )
                        : widget.guessed
                        ? _emojiPlaceholder(true)
                        : _unguessedPlaceholder(),
                  ),
                ),
                // Label area
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: widget.guessed
                            ? AppColors.correctGreen.withValues(alpha: 0.2)
                            : AppColors.deepPurple.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (widget.guessed)
                        Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.correctGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          widget.guessed
                              ? widget.animal.name
                              : '#${widget.index + 1}',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: widget.guessed
                                ? AppColors.correctGreen
                                : AppColors.deepPurple.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _skeletonLoader(bool guessed) {
    return ShimmerLoading(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
    );
  }

  Widget _emojiPlaceholder(bool guessed) {
    return Center(
      child: Text(
        widget.animal.emoji ?? (guessed ? '\u{2705}' : '\u{1F43E}'),
        style: const TextStyle(fontSize: 36),
      ),
    );
  }

  Widget _unguessedPlaceholder() {
    return Center(
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.deepPurple.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '?',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.deepPurple.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
