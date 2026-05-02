import 'package:flutter/material.dart';

import '../../wallet/providers/wallet_state_scope.dart';

Future<bool> showSensitiveActionAuthSheet(
  BuildContext context, {
  required String title,
  required String reason,
  String passwordLabel = '输入钱包密码',
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _SensitiveActionAuthSheet(
      title: title,
      reason: reason,
      passwordLabel: passwordLabel,
    ),
  );
  return result ?? false;
}

class _SensitiveActionAuthSheet extends StatefulWidget {
  const _SensitiveActionAuthSheet({
    required this.title,
    required this.reason,
    required this.passwordLabel,
  });

  final String title;
  final String reason;
  final String passwordLabel;

  @override
  State<_SensitiveActionAuthSheet> createState() =>
      _SensitiveActionAuthSheetState();
}

class _SensitiveActionAuthSheetState extends State<_SensitiveActionAuthSheet> {
  final _controller = TextEditingController();
  bool _obscureText = true;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 6,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            widget.reason,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: _obscureText,
            autofocus: true,
            decoration: InputDecoration(
              labelText: widget.passwordLabel,
              errorText: _errorText,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureText = !_obscureText),
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _verifyPassword,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('验证密码'),
            ),
          ),
          if (state.canUseBiometrics) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _verifyBiometrics,
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('使用生物识别'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _verifyPassword() async {
    setState(() => _isSubmitting = true);
    final approved = await context.walletState.authorizeSensitiveAction(
      password: _controller.text,
      reason: widget.reason,
    );
    if (!mounted) {
      return;
    }
    if (approved) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isSubmitting = false;
      _errorText = '验证失败，请重试';
    });
  }

  Future<void> _verifyBiometrics() async {
    setState(() => _isSubmitting = true);
    final approved = await context.walletState.authorizeSensitiveAction(
      reason: widget.reason,
    );
    if (!mounted) {
      return;
    }
    if (approved) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isSubmitting = false;
      _errorText = '生物识别验证未通过';
    });
  }
}
