import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Displays a network image first, then a local asset image,
/// and finally an emoji if both images fail.
class FoodImage extends StatelessWidget {
  final String? url;
  final String? asset;
  final String emoji;
  final double? width;
  final double? height;
  final double radius;
  final double emojiSize;

  const FoodImage({
    super.key,
    required this.emoji,
    this.url,
    this.asset,
    this.width,
    this.height,
    this.radius = 16,
    this.emojiSize = 40,
  });

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.orangeSoft,
            AppColors.creamDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: emojiSize),
      ),
    );
  }

  Widget _assetImage() {
    if (asset == null || asset!.isEmpty) {
      return _fallback();
    }

    return Image.asset(
      asset!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _networkImage() {
    if (url == null || url!.isEmpty) {
      return _assetImage();
    }

    return Image.network(
      url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return SizedBox(
          width: width,
          height: height,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.orange,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _assetImage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: _networkImage(),
    );
  }
}
