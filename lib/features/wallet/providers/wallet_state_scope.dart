import 'package:flutter/widgets.dart';

import '../../../app/wallet_dependencies.dart';
import 'wallet_state.dart';

class WalletStateProvider extends StatefulWidget {
  const WalletStateProvider({
    super.key,
    required this.child,
    required this.dependencies,
  });

  final Widget child;
  final WalletAppDependencies dependencies;

  @override
  State<WalletStateProvider> createState() => _WalletStateProviderState();
}

class _WalletStateProviderState extends State<WalletStateProvider>
    with WidgetsBindingObserver {
  late final WalletAppState _state = WalletAppState(
    dependencies: widget.dependencies,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _state.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _state.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _state.onLifecycleChanged(state);
  }

  @override
  Widget build(BuildContext context) {
    return WalletStateScope(state: _state, child: widget.child);
  }
}

class WalletStateScope extends InheritedNotifier<WalletAppState> {
  const WalletStateScope({
    super.key,
    required WalletAppState state,
    required super.child,
  }) : super(notifier: state);

  static WalletAppState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<WalletStateScope>();
    assert(scope != null, 'WalletStateScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}

extension WalletStateContext on BuildContext {
  WalletAppState get walletState => WalletStateScope.of(this);
}
