import 'package:flutter/material.dart';

import '../features/security/pages/password_unlock_page.dart';
import '../shared/widgets/animated_brand_mark.dart';
import '../features/wallet/providers/wallet_state_scope.dart';
import 'brand/app_brand.dart';
import 'navigation/app_shell.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'wallet_dependencies.dart';

class WalletApp extends StatelessWidget {
  WalletApp({super.key, WalletAppDependencies? dependencies})
    : _dependencies = dependencies ?? WalletAppDependencies.production();

  final WalletAppDependencies _dependencies;

  @override
  Widget build(BuildContext context) {
    return WalletStateProvider(
      dependencies: _dependencies,
      child: Builder(
        builder: (context) {
          final state = WalletStateScope.of(context);
          return MaterialApp(
            title: AppBrand.name,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: !state.isInitialized
                ? const _BootLoadingPage()
                : state.isUnlocked
                ? const AppShell()
                : const PasswordUnlockPage(),
          );
        },
      ),
    );
  }
}

class _BootLoadingPage extends StatelessWidget {
  const _BootLoadingPage();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }
}
