import 'package:flutter/material.dart';

import '../../app/brand/app_brand.dart';

class AnimatedBrandMark extends StatelessWidget {
  const AnimatedBrandMark({super.key, this.size = 118});

  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 760),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((1 - value) * -18, 0),
            child: Transform.scale(scale: 0.96 + value * 0.04, child: child),
          ),
        );
      },
      child: SizedBox.square(
        dimension: size,
        child: Image.asset(AppBrand.markAsset, fit: BoxFit.contain),
      ),
    );
  }
}
