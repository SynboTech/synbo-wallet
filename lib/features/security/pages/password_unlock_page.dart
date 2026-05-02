import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/brand/app_brand.dart';
import '../../../shared/widgets/animated_brand_mark.dart';
import '../../wallet/providers/wallet_state_scope.dart';

class PasswordUnlockPage extends StatefulWidget {
  const PasswordUnlockPage({super.key});

  @override
  State<PasswordUnlockPage> createState() => _PasswordUnlockPageState();
}

class _PasswordUnlockPageState extends State<PasswordUnlockPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _obscureText = true;
  bool _isSubmitting = false;
  String? _errorText;

  bool get _canUnlock => _controller.text.trim().isNotEmpty && !_isSubmitting;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _errorText = null;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = context.walletState;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _UnlockBrandPattern(),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 22, 28, 30),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(constraints.maxHeight - 52, 0),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 88),
                        _BrandLockup(colorScheme: colorScheme),
                        const SizedBox(height: 142),
                        _PasswordField(
                          controller: _controller,
                          focusNode: _focusNode,
                          obscureText: _obscureText,
                          errorText: _errorText,
                          onToggleObscure: () =>
                              setState(() => _obscureText = !_obscureText),
                          onSubmitted: _canUnlock ? _unlock : null,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: _canUnlock
                                  ? const Color(0xFF111214)
                                  : colorScheme.onSurface.withValues(
                                      alpha: 0.38,
                                    ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _canUnlock ? _unlock : null,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '解锁',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ),
                        if (state.canUseBiometrics) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isSubmitting
                                  ? null
                                  : _unlockWithBiometrics,
                              icon: const Icon(Icons.fingerprint_rounded),
                              label: const Text('使用生物识别'),
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        TextButton(
                          onPressed: _showRecoveryNotice,
                          child: const Text(
                            '忘记密码？',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _unlock() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    final isValid = await context.walletState.unlock(_controller.text);
    if (!mounted) {
      return;
    }
    setState(() {
      _isSubmitting = false;
      _errorText = isValid ? null : '密码错误，请重新输入';
    });
  }

  Future<void> _unlockWithBiometrics() async {
    setState(() => _isSubmitting = true);
    final isValid = await context.walletState.unlockWithBiometrics();
    if (!mounted) {
      return;
    }
    setState(() {
      _isSubmitting = false;
      _errorText = isValid ? null : '生物识别验证未通过';
    });
  }

  void _showRecoveryNotice() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('请通过助记词或私钥在安全环境中恢复钱包')));
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AnimatedBrandMark(),
        const SizedBox(height: 22),
        Text(
          AppBrand.name,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.obscureText,
    required this.errorText,
    required this.onToggleObscure,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final String? errorText;
  final VoidCallback onToggleObscure;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmitted?.call(),
      decoration: InputDecoration(
        hintText: '输入密码',
        errorText: errorText,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: obscureText ? '显示密码' : '隐藏密码',
          onPressed: onToggleObscure,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _UnlockBrandPattern extends StatelessWidget {
  const _UnlockBrandPattern();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 170,
        child: CustomPaint(painter: _UnlockBrandPatternPainter()),
      ),
    );
  }
}

class _UnlockBrandPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final yellow = Paint()
      ..color = const Color(0xFFF9BE00).withValues(alpha: 0.18);
    final dark = Paint()..color = Colors.black.withValues(alpha: 0.04);
    _drawHex(canvas, Offset(size.width * 0.22, size.height * 0.92), 92, yellow);
    _drawHex(canvas, Offset(size.width * 0.78, size.height * 0.92), 92, yellow);
    _drawHex(canvas, Offset(size.width * 0.50, size.height * 1.08), 100, dark);
  }

  void _drawHex(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = -1.5708 + i * 1.0472;
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
    canvas.drawPath(path..close(), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
