import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../security/pages/password_setup_page.dart';
import '../../wallet/providers/wallet_state_scope.dart';
import '../widgets/settings_group.dart';

class SecurityPrivacyPage extends StatelessWidget {
  const SecurityPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    return Scaffold(
      appBar: AppBar(title: const Text('安全与隐私')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SettingsGroup(
              title: '访问安全',
              children: [
                SettingsItem(
                  icon: Icons.password_outlined,
                  title: '修改密码',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PasswordSetupPage(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint_rounded),
                  title: const Text('Face ID / 指纹'),
                  value: state.biometricEnabled,
                  onChanged: (value) =>
                      state.updateSecurity(biometricEnabled: value),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_clock_outlined),
                  title: const Text('自动锁定'),
                  trailing: DropdownButton<int>(
                    value: state.autoLockMinutes,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 min')),
                      DropdownMenuItem(value: 5, child: Text('5 min')),
                      DropdownMenuItem(value: 15, child: Text('15 min')),
                      DropdownMenuItem(value: 30, child: Text('30 min')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        state.updateSecurity(autoLockMinutes: value);
                      }
                    },
                  ),
                ),
              ],
            ),
            SettingsGroup(
              title: '隐私',
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.visibility_off_outlined),
                  title: const Text('隐藏资产金额'),
                  value: state.hideBalances,
                  onChanged: (_) => state.toggleHideBalances(),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.screenshot_monitor_outlined),
                  title: const Text('防截屏'),
                  value: state.screenshotProtectionEnabled,
                  onChanged: (value) =>
                      state.updateSecurity(screenshotProtectionEnabled: value),
                ),
              ],
            ),
            SettingsGroup(
              title: '缓存',
              children: [
                SettingsItem(
                  icon: Icons.cleaning_services_outlined,
                  title: '清除缓存',
                  subtitle: state.lastRefreshedAt == null
                      ? 'No cached refresh timestamp'
                      : 'Cached balance refresh state',
                  onTap: () {
                    state.clearCache();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Text(
                'Security-critical actions keep the visual state explicit and reserve adapters for secure storage, biometrics, WalletConnect permissions, and chain-specific signing.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
