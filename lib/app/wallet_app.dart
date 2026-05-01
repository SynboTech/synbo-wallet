import 'package:flutter/material.dart';

import '../features/security/pages/password_unlock_page.dart';
import '../features/wallet/providers/wallet_state_scope.dart';
import 'brand/app_brand.dart';
import 'navigation/app_shell.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

class WalletApp extends StatefulWidget {
  const WalletApp({super.key});

  @override
  State<WalletApp> createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> {
  bool _isUnlocked = false;

  @override
  Widget build(BuildContext context) {
    return WalletStateProvider(
      child: MaterialApp(
        title: AppBrand.name,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: _isUnlocked
            ? const AppShell()
            : PasswordUnlockPage(
                onUnlocked: () => setState(() => _isUnlocked = true),
              ),
      ),
    );
  }
}
