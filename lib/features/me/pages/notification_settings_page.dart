import 'package:flutter/material.dart';

import '../../wallet/providers/wallet_state_scope.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    return Scaffold(
      appBar: AppBar(title: const Text('通知设置')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              value: state.notificationsEnabled,
              onChanged: state.toggleNotifications,
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text('交易状态通知'),
              subtitle: const Text('Pending, Success, Failed'),
            ),
            const Divider(height: 1),
            SwitchListTile(
              value: state.notificationsEnabled,
              onChanged: state.toggleNotifications,
              secondary: const Icon(Icons.security_outlined),
              title: const Text('安全提醒'),
              subtitle: const Text('Signature and approval alerts'),
            ),
          ],
        ),
      ),
    );
  }
}
