import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';

/// 1) Custom Cache config: TTL + max objects
class AppImageCache {
  static final CacheManager instance = CacheManager(
    Config(
      'my_app_images_cache',
      stalePeriod: const Duration(days: 7), // ৭ দিন পর রিফ্রেশ করবে
      maxNrOfCacheObjects: 300,            // সর্বোচ্চ ৩০০ ফাইল
      repo: JsonCacheInfoRepository(databaseName: 'my_app_images'),
      fileService: HttpFileService(),
    ),
  );
}

/// 2) Helper: logical px -> real px (DPR অনুযায়ী)
int? _cachePx(BuildContext context, double? logical) {
  if (logical == null) return null;
  final dpr = MediaQuery.of(context).devicePixelRatio;
  return (logical * dpr).round();
}

/// 3) Smart widget: cache আছে কিনা দেখে তবে shimmer দেখায়
class FirstTimeShimmerImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const FirstTimeShimmerImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<FirstTimeShimmerImage> createState() => _FirstTimeShimmerImageState();
}

class _FirstTimeShimmerImageState extends State<FirstTimeShimmerImage> {
  late final Future<bool> _isCachedFuture;

  Future<bool> _isCached(String url) async {
    final fileInfo =
    await AppImageCache.instance.getFileFromCache(url);
    return fileInfo != null && await fileInfo.file.exists();
  }

  @override
  void initState() {
    super.initState();
    _isCachedFuture = _isCached(widget.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.zero;
    return ClipRRect(
      borderRadius: radius,
      child: FutureBuilder<bool>(
        future: _isCachedFuture,
        builder: (context, snap) {
          final cached = snap.data == true;

          return CachedNetworkImage(
            imageUrl: widget.imageUrl,
            fit: widget.fit,
            width: widget.width,
            height: widget.height,
            cacheManager: AppImageCache.instance,

            // Cache-hit হলে shimmer/placeholder বাদ:
            placeholder: cached
                ? null
                : (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: widget.width,
                height: widget.height,
                color: Colors.white,
              ),
            ),

            // Cache-hit হলে fadeIn ছোট/শূন্য, যাতে flicker না হয়
            fadeInDuration:
            cached ? const Duration(milliseconds: 0)
                : const Duration(milliseconds: 300),

            // মেমরি অপ্টিমাইজ
            memCacheWidth: _cachePx(context, widget.width),
            memCacheHeight: _cachePx(context, widget.height),

            errorWidget: (context, url, error) =>
            const Icon(Icons.broken_image),
          );
        },
      ),
    );
  }
}