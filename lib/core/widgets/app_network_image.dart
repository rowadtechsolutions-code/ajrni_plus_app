import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final Alignment alignment;
  final Widget fallback;
  final Widget? placeholder;
  final int? memoryCacheWidth;
  final int? memoryCacheHeight;
  final int? diskCacheWidth;
  final int? diskCacheHeight;

  const AppNetworkImage({
    super.key,
    required this.url,
    required this.fallback,
    this.placeholder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.memoryCacheWidth,
    this.memoryCacheHeight,
    this.diskCacheWidth,
    this.diskCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty || !url.startsWith('http')) return fallback;
    return CachedNetworkImage(
      imageUrl: url,
      cacheKey: url,
      fit: fit,
      alignment: alignment,
      memCacheWidth: memoryCacheWidth,
      memCacheHeight: memoryCacheHeight,
      maxWidthDiskCache: diskCacheWidth,
      maxHeightDiskCache: diskCacheHeight,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholderFadeInDuration: Duration.zero,
      placeholder: (_, __) => placeholder ?? fallback,
      errorWidget: (_, __, ___) => fallback,
    );
  }
}
