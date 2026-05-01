import 'package:flutter/widgets.dart';

import 'wallet_state.dart';

class WalletStateProvider extends StatefulWidget {
  const WalletStateProvider({super.key, required this.child});

  final Widget child;

  @override
  State<WalletStateProvider> createState() => _WalletStateProviderState();
}

class _WalletStateProviderState extends State<WalletStateProvider> {
  late final WalletAppState _state = WalletAppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
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
