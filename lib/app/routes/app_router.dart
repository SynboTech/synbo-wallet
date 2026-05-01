import 'package:flutter/material.dart';

import '../../features/me/pages/authorization_management_page.dart';
import '../../features/me/pages/help_center_page.dart';
import '../../features/me/pages/invite_page.dart';
import '../../features/me/pages/network_management_page.dart';
import '../../features/me/pages/notification_settings_page.dart';
import '../../features/me/pages/security_privacy_page.dart';
import '../../features/me/pages/wallet_management_page.dart';

abstract final class AppRouteNames {
  static const walletManagement = '/me/wallets';
  static const networkManagement = '/me/networks';
  static const securityPrivacy = '/me/security';
  static const authorizationManagement = '/me/authorizations';
  static const invite = '/me/invite';
  static const notifications = '/me/notifications';
  static const helpCenter = '/me/help';
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      AppRouteNames.walletManagement => _route(const WalletManagementPage()),
      AppRouteNames.networkManagement => _route(const NetworkManagementPage()),
      AppRouteNames.securityPrivacy => _route(const SecurityPrivacyPage()),
      AppRouteNames.authorizationManagement => _route(
        const AuthorizationManagementPage(),
      ),
      AppRouteNames.invite => _route(const InvitePage()),
      AppRouteNames.notifications => _route(const NotificationSettingsPage()),
      AppRouteNames.helpCenter => _route(const HelpCenterPage()),
      _ => null,
    };
  }

  static MaterialPageRoute<void> _route(Widget page) {
    return MaterialPageRoute<void>(builder: (_) => page);
  }
}
