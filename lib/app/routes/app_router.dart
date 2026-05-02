import 'package:flutter/material.dart';

import '../../features/home/pages/capital_page.dart';
import '../../features/home/models/square_models.dart';
import '../../features/home/pages/portfolio_detail_page.dart';
import '../../features/home/pages/square_post_detail_page.dart';
import '../../features/me/pages/authorization_management_page.dart';
import '../../features/me/pages/help_center_page.dart';
import '../../features/me/pages/invite_page.dart';
import '../../features/me/pages/network_management_page.dart';
import '../../features/me/pages/notification_settings_page.dart';
import '../../features/me/pages/security_privacy_page.dart';
import '../../features/me/pages/wallet_management_page.dart';

abstract final class AppRouteNames {
  static const capital = '/capital';
  static const portfolioDetail = '/portfolio/detail';
  static const squarePostDetail = '/square/post';
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
      AppRouteNames.capital => _route(const CapitalPage()),
      AppRouteNames.portfolioDetail => _route(
        _buildPortfolioDetailPage(settings.arguments as Map<String, dynamic>),
      ),
      AppRouteNames.squarePostDetail => _route(
        SquarePostDetailPage(post: settings.arguments as SquarePost),
      ),
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

  static PortfolioDetailPage _buildPortfolioDetailPage(
    Map<String, dynamic> args,
  ) {
    return PortfolioDetailPage(
      name: args['name'] as String,
      symbol: args['symbol'] as String,
      price: args['price'] as String,
      change: args['change'] as String,
      amount: args['amount'] as String,
      totalValue: args['totalValue'] as String,
      color: args['color'] as Color,
      badge: args['badge'] as String?,
    );
  }
}
