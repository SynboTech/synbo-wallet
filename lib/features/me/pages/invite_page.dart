import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/brand/app_brand.dart';

class InvitePage extends StatelessWidget {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('推荐')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          children: const [
            _InviteHeader(),
            SizedBox(height: 34),
            _CopySection(
              label: '推荐码',
              value: AppBrand.referralCode,
              copyMessage: '推荐码已复制',
            ),
            SizedBox(height: 22),
            _CopySection(
              label: '推荐链接',
              value: AppBrand.referralLink,
              copyMessage: '推荐链接已复制',
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: SizedBox(
          height: 58,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF111214),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _copy(context, AppBrand.referralLink, '推荐链接已复制'),
            child: const Text(
              '推荐好友',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

class _InviteHeader extends StatelessWidget {
  const _InviteHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Image.asset(AppBrand.markAsset, fit: BoxFit.contain),
        ),
        const SizedBox(height: 22),
        Text(
          '将您的推荐码分享给好友',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Text(
          '推荐奖励因活动而异。详情请查看 SYNBO 活动规则。',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _CopySection extends StatelessWidget {
  const _CopySection({
    required this.label,
    required this.value,
    required this.copyMessage,
  });

  final String label;
  final String value;
  final String copyMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Material(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _copy(context, value, copyMessage),
            child: Container(
              height: 58,
              padding: const EdgeInsets.fromLTRB(14, 0, 10, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.85),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '复制',
                    onPressed: () => _copy(context, value, copyMessage),
                    icon: const Icon(Icons.copy_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _copy(BuildContext context, String value, String message) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
