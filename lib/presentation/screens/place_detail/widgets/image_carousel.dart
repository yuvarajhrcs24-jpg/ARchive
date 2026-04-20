import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:archive/core/constants/app_colors.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: 280,
        color: AppColors.shimmerBase,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64, color: Colors.white38),
        ),
      );
    }

    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index, realIndex) {
            return CachedNetworkImage(
              imageUrl: widget.imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, __) => Container(color: AppColors.shimmerBase),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.shimmerBase,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white38,
                  size: 48,
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 280,
            viewportFraction: 1.0,
            enableInfiniteScroll: widget.imageUrls.length > 1,
            onPageChanged: (index, _) => setState(() => _current = index),
          ),
        ),
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.imageUrls.asMap().entries.map((entry) {
                return Container(
                  width: _current == entry.key ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _current == entry.key
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
