import 'package:flutter/material.dart';

import '../../../shared/widgets/chain_logo.dart';
import '../../wallet/models/wallet_models.dart';
import '../../wallet/providers/wallet_state_scope.dart';

class NetworkManagementPage extends StatelessWidget {
  const NetworkManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    final networks = state.networks;
    final currentNetwork = state.currentNetwork;

    return Scaffold(
      appBar: AppBar(
        title: const Text('网络管理'),
        actions: [
          IconButton(
            tooltip: '添加自定义网络',
            onPressed: () => _showNetworkForm(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
          children: [
            _NetworkSummary(
              count: networks.length,
              currentNetworkName: currentNetwork.name,
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest
                    .withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.72
                          : 0.64,
                    ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  for (var index = 0; index < networks.length; index++) ...[
                    _NetworkTile(
                      network: networks[index],
                      isActive: networks[index].id == currentNetwork.id,
                      onSwitch: () => state.switchNetwork(networks[index].id),
                      onEdit: () =>
                          _showNetworkForm(context, network: networks[index]),
                      onDelete: () =>
                          _confirmDeleteNetwork(context, networks[index]),
                    ),
                    if (index != networks.length - 1) const _InsetDivider(),
                  ],
                  const _InsetDivider(),
                  _AddNetworkTile(onTap: () => _showNetworkForm(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNetworkForm(
    BuildContext context, {
    ChainNetwork? network,
  }) async {
    final state = context.walletState;
    final name = TextEditingController(text: network?.name ?? '');
    final symbol = TextEditingController(text: network?.nativeSymbol ?? '');
    final rpc = TextEditingController(text: network?.rpcUrl ?? '');
    final explorer = TextEditingController(text: network?.explorerUrl ?? '');
    final isEdit = network != null;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _NetworkFormDialog(
        network: network,
        nameController: name,
        symbolController: symbol,
        rpcController: rpc,
        explorerController: explorer,
      ),
    );
    if (saved == true) {
      if (isEdit) {
        state.updateNetwork(
          id: network.id,
          name: name.text,
          nativeSymbol: symbol.text,
          rpcUrl: rpc.text,
          explorerUrl: explorer.text,
        );
      } else {
        state.addCustomNetwork(
          name: name.text,
          nativeSymbol: symbol.text,
          rpcUrl: rpc.text,
          explorerUrl: explorer.text,
        );
      }
    }
    name.dispose();
    symbol.dispose();
    rpc.dispose();
    explorer.dispose();
  }

  Future<void> _confirmDeleteNetwork(
    BuildContext context,
    ChainNetwork network,
  ) async {
    if (!network.isCustom) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('内置网络不可删除，可编辑 RPC 与 Explorer')),
      );
      return;
    }

    final state = context.walletState;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteNetworkDialog(network: network),
    );
    if (confirmed == true) {
      state.removeCustomNetwork(network.id);
    }
  }
}

class _NetworkSummary extends StatelessWidget {
  const _NetworkSummary({
    required this.count,
    required this.currentNetworkName,
  });

  final int count;
  final String currentNetworkName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            '已启用网络',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              '$count 条 · 当前 $currentNetworkName',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkTile extends StatelessWidget {
  const _NetworkTile({
    required this.network,
    required this.isActive,
    required this.onSwitch,
    required this.onEdit,
    required this.onDelete,
  });

  final ChainNetwork network;
  final bool isActive;
  final VoidCallback onSwitch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isActive ? null : onSwitch,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
          child: Row(
            children: [
              ChainLogo(
                chainId: network.id,
                name: network.name,
                colorValue: network.colorValue,
                size: 32,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            network.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 6),
                          _TinyPill(label: '当前', color: colorScheme.primary),
                        ],
                        if (network.isCustom) ...[
                          const SizedBox(width: 6),
                          _TinyPill(
                            label: '自定义',
                            color: Color(network.colorValue),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${network.nativeSymbol} · RPC ${_displayHost(network.rpcUrl)} · Explorer ${_displayHost(network.explorerUrl)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              if (isActive)
                Icon(Icons.check_circle_rounded, color: colorScheme.primary)
              else
                SizedBox(
                  width: 24,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                  ),
                ),
              const SizedBox(width: 2),
              _InlineActionButton(
                tooltip: network.isCustom ? '编辑网络' : '编辑 RPC',
                icon: Icons.edit_outlined,
                onPressed: onEdit,
              ),
              _InlineActionButton(
                tooltip: network.isCustom ? '删除网络' : '内置网络不可删除',
                icon: Icons.delete_outline,
                onPressed: network.isCustom ? onDelete : null,
                destructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddNetworkTile extends StatelessWidget {
  const _AddNetworkTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: colorScheme.primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '添加自定义网络',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '配置网络名称、RPC 与区块浏览器',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineActionButton extends StatelessWidget {
  const _InlineActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = destructive
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: onPressed == null
              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
              : color,
        ),
      ),
    );
  }
}

class _NetworkFormDialog extends StatefulWidget {
  const _NetworkFormDialog({
    required this.network,
    required this.nameController,
    required this.symbolController,
    required this.rpcController,
    required this.explorerController,
  });

  final ChainNetwork? network;
  final TextEditingController nameController;
  final TextEditingController symbolController;
  final TextEditingController rpcController;
  final TextEditingController explorerController;

  @override
  State<_NetworkFormDialog> createState() => _NetworkFormDialogState();
}

class _NetworkFormDialogState extends State<_NetworkFormDialog> {
  final _formKey = GlobalKey<FormState>();

  bool get _isEdit => widget.network != null;
  bool get _isSystemNetwork => _isEdit && !widget.network!.isCustom;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final network = widget.network;
    final logoName = network?.name ?? widget.nameController.text;
    final logoColor = network?.colorValue ?? 0xFF3E7C59;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ChainLogo(
                        chainId: network?.id ?? 'custom',
                        name: logoName.isEmpty ? 'Custom Network' : logoName,
                        colorValue: logoColor,
                        size: 42,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEdit ? '编辑网络' : '添加自定义网络',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _isSystemNetwork
                                  ? '内置网络仅允许修改 RPC 与 Explorer'
                                  : '保存后可在钱包首页切换使用',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _NetworkField(
                    controller: widget.nameController,
                    label: '网络名称',
                    icon: Icons.public_rounded,
                    enabled: !_isSystemNetwork,
                    validator: _requiredValidator('请输入网络名称'),
                  ),
                  const SizedBox(height: 10),
                  _NetworkField(
                    controller: widget.symbolController,
                    label: '原生代币符号',
                    icon: Icons.toll_outlined,
                    enabled: !_isSystemNetwork,
                    textCapitalization: TextCapitalization.characters,
                    validator: _requiredValidator('请输入原生代币符号'),
                  ),
                  const SizedBox(height: 10),
                  _NetworkField(
                    controller: widget.rpcController,
                    label: 'RPC URL',
                    icon: Icons.settings_ethernet_rounded,
                    keyboardType: TextInputType.url,
                    validator: _urlValidator('请输入有效的 RPC URL'),
                  ),
                  const SizedBox(height: 10),
                  _NetworkField(
                    controller: widget.explorerController,
                    label: '区块浏览器 URL',
                    icon: Icons.travel_explore_rounded,
                    keyboardType: TextInputType.url,
                    validator: _urlValidator('请输入有效的区块浏览器 URL'),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '请确认 RPC 来源可信。错误或恶意 RPC 可能影响余额展示、交易广播与隐私。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: _save,
                          child: const Text('保存'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  FormFieldValidator<String> _requiredValidator(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }

  FormFieldValidator<String> _urlValidator(String message) {
    return (value) {
      final trimmed = value?.trim() ?? '';
      final uri = Uri.tryParse(trimmed);
      if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
        return message;
      }
      return null;
    };
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(true);
    }
  }
}

class _NetworkField extends StatelessWidget {
  const _NetworkField({
    required this.controller,
    required this.label,
    required this.icon,
    this.enabled = true,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 19),
      ),
    );
  }
}

class _DeleteNetworkDialog extends StatelessWidget {
  const _DeleteNetworkDialog({required this.network});

  final ChainNetwork network;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ChainLogo(
                  chainId: network.id,
                  name: network.name,
                  colorValue: network.colorValue,
                  size: 42,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '删除 ${network.name}？',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '删除后该自定义网络不会再出现在网络切换列表中。资产不会被链上删除，但本地网络配置会被移除。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('删除'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  const _TinyPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InsetDivider extends StatelessWidget {
  const _InsetDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 54,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.52),
    );
  }
}

String _displayHost(String value) {
  final uri = Uri.tryParse(value.trim());
  final host = uri?.host ?? '';
  if (host.isEmpty) {
    return value.trim().isEmpty ? '未配置' : value.trim();
  }
  return host.replaceFirst(RegExp(r'^www\.'), '');
}
