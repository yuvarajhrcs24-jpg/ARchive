import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:archive/core/constants/app_colors.dart';

class LoadingShimmer extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const LoadingShimmer({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class PlaceCardShimmer extends StatelessWidget {
  const PlaceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingShimmer(height: 14, width: 120),
                  SizedBox(height: 6),
                  LoadingShimmer(height: 10, width: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListItemShimmer extends StatelessWidget {
  const ListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            LoadingShimmer(height: 70, width: 70),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoadingShimmer(height: 14),
                  SizedBox(height: 8),
                  LoadingShimmer(height: 10, width: 150),
                  SizedBox(height: 6),
                  LoadingShimmer(height: 10, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
