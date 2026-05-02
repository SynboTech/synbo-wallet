import 'package:flutter/material.dart';

import '../../../shared/utils/wallet_formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/info_row.dart';
import '../../wallet/models/wallet_models.dart';
import '../../wallet/pages/wallet_setup_flow_page.dart';
import '../../wallet/providers/wallet_state_scope.dart';
import '../../security/widgets/sensitive_action_auth_sheet.dart';
import '../widgets/settings_group.dart';
import 'mnemonic_backup_page.dart';

class WalletManagementPage extends StatelessWidget {
  const WalletManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    return Scaffold(
      appBar: AppBar(title: const Text('钱包管理')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                children: [
                  InfoRow(label: '当前钱包', value: state.currentWallet.name),
                  InfoRow(label: '当前账户', value: state.currentAccount.name),
                  InfoRow(
                    label: '地址',
                    value: compactAddress(state.currentAccount.address),
                  ),
                ],
              ),
            ),
            SettingsGroup(
              title: '钱包',
              children: [
                SettingsItem(
                  icon: Icons.add_circle_outline,
                  title: '创建钱包',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const WalletSetupFlowPage(
                        mode: WalletSetupMode.create,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                SettingsItem(
                  icon: Icons.download_outlined,
                  title: '导入钱包',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const WalletSetupFlowPage(
                        mode: WalletSetupMode.importExisting,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                SettingsItem(
                  icon: Icons.edit_outlined,
                  title: '钱包重命名',
                  onTap: () => _rename(context),
                ),
                const Divider(height: 1),
                SettingsItem(
                  icon: Icons.switch_account_outlined,
                  title: '账户切换',
                  onTap: () => _switchAccount(context),
                ),
              ],
            ),
            SettingsGroup(
              title: '备份与导出',
              children: [
                SettingsItem(
                  icon: Icons.security_outlined,
                  title: '备份助记词',
                  onTap: () => _openMnemonicBackup(context),
                ),
                const Divider(height: 1),
                SettingsItem(
                  icon: Icons.vpn_key_outlined,
                  title: '导出私钥',
                  onTap: () => _guardSensitiveAction(context, '导出私钥'),
                ),
                const Divider(height: 1),
                SettingsItem(
                  icon: Icons.delete_outline,
                  title: '删除钱包',
                  destructive: true,
                  onTap: () => _guardSensitiveAction(context, '删除钱包'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context) async {
    final state = context.walletState;
    final controller = TextEditingController(text: state.currentWallet.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('钱包重命名'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Wallet name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null) {
      state.renameCurrentWallet(result);
    }
  }

  void _switchAccount(BuildContext context) {
    final state = context.walletState;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              '账户切换',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            for (final account in state.currentWallet.accounts)
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: Text(account.name),
                subtitle: Text(compactAddress(account.address)),
                trailing: account.id == state.currentAccount.id
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () {
                  state.switchAccount(account.id);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMnemonicBackup(BuildContext context) async {
    final approved = await showSensitiveActionAuthSheet(
      context,
      title: '备份助记词',
      reason: '查看恢复助记词前请再次验证身份。',
    );
    if (!approved || !context.mounted) {
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MnemonicBackupPage()));
  }

  Future<void> _guardSensitiveAction(BuildContext context, String title) async {
    final approved = await showSensitiveActionAuthSheet(
      context,
      title: title,
      reason: '继续前请验证身份，避免高风险操作被误触发。',
    );
    if (!approved || !context.mounted) {
      return;
    }
    _showRiskDialog(context, title);
  }

  void _showRiskDialog(BuildContext context, String title) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text(
          'This action must be protected by password verification and secure storage in production.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
