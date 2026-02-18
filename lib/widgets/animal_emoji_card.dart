import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/env.dart';
import '../theme/app_theme.dart';
import 'shimmer_loading.dart';

class AnimalEmojiCard extends StatelessWidget {
  final String emoji;
  final String? imageUrl;

  const AnimalEmojiCard({super.key, required this.emoji, this.imageUrl});

  String? _resolveUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('http')) return url;
    return '${Env.originUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveUrl(imageUrl);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardSize = (screenWidth - 48) * 0.85;
    final clampedSize = cardSize.clamp(220.0, 320.0);

    return Container(
      width: clampedSize,
      height: clampedSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepPurple.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.deepPurple.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: resolvedUrl != null
            ? CachedNetworkImage(
                imageUrl: resolvedUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _skeletonLoader(),
                errorWidget: (context, url, error) => _emojiFallback(),
              )
            : _emojiFallback(),
      ),
    );
  }

  Widget _skeletonLoader() {
    return ShimmerLoading(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
    );
  }

  Widget _emojiFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.deepPurple.withValues(alpha: 0.08),
            AppColors.deepPurple.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 90))),
    );
  }
}
