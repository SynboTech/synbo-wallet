import 'dart:math' as math;

import 'package:flutter/material.dart';

class ChainLogo extends StatelessWidget {
  const ChainLogo({
    super.key,
    required this.chainId,
    required this.name,
    required this.colorValue,
    this.size = 40,
    this.borderColor,
    this.borderWidth = 0,
  });

  final String chainId;
  final String name;
  final int colorValue;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final type = _resolveChainLogoType(chainId, name);
    final colors = _ChainLogoColors.resolve(type, Color(colorValue));
    final isCustom = type == _ChainLogoType.custom;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.background,
        shape: BoxShape.circle,
        border: borderColor == null || borderWidth == 0
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: isCustom
            ? Text(
                _initial(name),
                style: TextStyle(
                  color: colors.primary,
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              )
            : CustomPaint(
                size: Size.square(size),
                painter: _ChainLogoPainter(type: type, colors: colors),
              ),
      ),
    );
  }
}

enum _ChainLogoType { ethereum, bnb, polygon, arbitrum, base, custom }

_ChainLogoType _resolveChainLogoType(String chainId, String name) {
  final value = '${chainId.toLowerCase()} ${name.toLowerCase()}';
  if (value.contains('ethereum')) {
    return _ChainLogoType.ethereum;
  }
  if (value.contains('bnb') || value.contains('binance')) {
    return _ChainLogoType.bnb;
  }
  if (value.contains('polygon') || value.contains('matic')) {
    return _ChainLogoType.polygon;
  }
  if (value.contains('arbitrum')) {
    return _ChainLogoType.arbitrum;
  }
  if (value.contains('base')) {
    return _ChainLogoType.base;
  }
  return _ChainLogoType.custom;
}

class _ChainLogoColors {
  const _ChainLogoColors({
    required this.background,
    required this.primary,
    this.secondary,
  });

  final Color background;
  final Color primary;
  final Color? secondary;

  static _ChainLogoColors resolve(_ChainLogoType type, Color fallback) {
    return switch (type) {
      _ChainLogoType.ethereum => const _ChainLogoColors(
        background: Color(0xFFE9ECFF),
        primary: Color(0xFF627EEA),
        secondary: Color(0xFF2F3A8D),
      ),
      _ChainLogoType.bnb => const _ChainLogoColors(
        background: Color(0xFFFFF4C7),
        primary: Color(0xFFF0B90B),
      ),
      _ChainLogoType.polygon => const _ChainLogoColors(
        background: Color(0xFFF0E7FF),
        primary: Color(0xFF8247E5),
      ),
      _ChainLogoType.arbitrum => const _ChainLogoColors(
        background: Color(0xFFE5F0FF),
        primary: Color(0xFF2D374B),
        secondary: Color(0xFF28A0F0),
      ),
      _ChainLogoType.base => const _ChainLogoColors(
        background: Color(0xFF0052FF),
        primary: Colors.white,
      ),
      _ChainLogoType.custom => _ChainLogoColors(
        background: fallback.withValues(alpha: 0.14),
        primary: fallback,
      ),
    };
  }
}

class _ChainLogoPainter extends CustomPainter {
  const _ChainLogoPainter({required this.type, required this.colors});

  final _ChainLogoType type;
  final _ChainLogoColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case _ChainLogoType.ethereum:
        _paintEthereum(canvas, size);
      case _ChainLogoType.bnb:
        _paintBnb(canvas, size);
      case _ChainLogoType.polygon:
        _paintPolygon(canvas, size);
      case _ChainLogoType.arbitrum:
        _paintArbitrum(canvas, size);
      case _ChainLogoType.base:
        _paintBase(canvas, size);
      case _ChainLogoType.custom:
        break;
    }
  }

  void _paintEthereum(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final primary = Paint()..color = colors.primary;
    final secondary = Paint()..color = colors.secondary ?? colors.primary;
    final highlight = Paint()..color = Colors.white.withValues(alpha: 0.7);

    final top = Path()
      ..moveTo(w * 0.5, h * 0.17)
      ..lineTo(w * 0.74, h * 0.52)
      ..lineTo(w * 0.5, h * 0.63)
      ..lineTo(w * 0.26, h * 0.52)
      ..close();
    canvas.drawPath(top, primary);

    final leftFacet = Path()
      ..moveTo(w * 0.5, h * 0.17)
      ..lineTo(w * 0.5, h * 0.63)
      ..lineTo(w * 0.26, h * 0.52)
      ..close();
    canvas.drawPath(leftFacet, highlight);

    final bottom = Path()
      ..moveTo(w * 0.5, h * 0.68)
      ..lineTo(w * 0.74, h * 0.56)
      ..lineTo(w * 0.5, h * 0.85)
      ..lineTo(w * 0.26, h * 0.56)
      ..close();
    canvas.drawPath(bottom, secondary);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.68)
        ..lineTo(w * 0.5, h * 0.85)
        ..lineTo(w * 0.26, h * 0.56)
        ..close(),
      primary,
    );
  }

  void _paintBnb(Canvas canvas, Size size) {
    final paint = Paint()..color = colors.primary;
    final unit = size.width * 0.14;
    final gap = size.width * 0.19;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(math.pi / 4);
    for (final offset in <Offset>[
      Offset.zero,
      Offset(-gap, 0),
      Offset(gap, 0),
      Offset(0, -gap),
      Offset(0, gap),
    ]) {
      final rect = Rect.fromCenter(center: offset, width: unit, height: unit);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(unit * 0.18)),
        paint,
      );
    }
    canvas.restore();
  }

  void _paintPolygon(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.065
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final left = Offset(size.width * 0.39, size.height * 0.51);
    final right = Offset(size.width * 0.61, size.height * 0.43);
    final radius = size.width * 0.15;

    canvas.drawPath(_hexagon(left, radius), paint);
    canvas.drawPath(_hexagon(right, radius), paint);
    canvas.drawLine(
      Offset(size.width * 0.49, size.height * 0.40),
      Offset(size.width * 0.52, size.height * 0.39),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.49, size.height * 0.61),
      Offset(size.width * 0.52, size.height * 0.59),
      paint,
    );
  }

  void _paintArbitrum(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeJoin = StrokeJoin.round;
    final stripe = Paint()
      ..color = colors.secondary ?? colors.primary
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round;
    final lightStripe = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..strokeWidth = size.width * 0.065
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      _hexagon(size.center(Offset.zero), size.width * 0.29),
      outline,
    );
    canvas.drawLine(
      Offset(size.width * 0.38, size.height * 0.70),
      Offset(size.width * 0.61, size.height * 0.31),
      stripe,
    );
    canvas.drawLine(
      Offset(size.width * 0.49, size.height * 0.72),
      Offset(size.width * 0.70, size.height * 0.38),
      lightStripe,
    );
  }

  void _paintBase(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.13;
    canvas.drawCircle(size.center(Offset.zero), size.width * 0.22, paint);
  }

  Path _hexagon(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = math.pi / 6 + i * math.pi / 3;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_ChainLogoPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.colors != colors;
  }
}

String _initial(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return trimmed.characters.first.toUpperCase();
}
