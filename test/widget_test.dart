import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_chain_wallet/app/wallet_dependencies.dart';
import 'package:multi_chain_wallet/app/wallet_app.dart';

Future<void> unlockApp(WidgetTester tester) async {
  expect(find.text('SYNBO'), findsOneWidget);
  await tester.enterText(find.byType(EditableText).first, '12345678');
  await tester.pump();
  await tester.tap(find.text('解锁'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows SYNBO unlock page before wallet shell', (tester) async {
    await tester.pumpWidget(
      WalletApp(dependencies: WalletAppDependencies.testing()),
    );
    await tester.pumpAndSettle();

    expect(find.text('SYNBO'), findsOneWidget);
    expect(find.text('输入密码'), findsOneWidget);
    expect(find.text('解锁'), findsOneWidget);
  });

  testWidgets('rejects an incorrect unlock password', (tester) async {
    await tester.pumpWidget(
      WalletApp(dependencies: WalletAppDependencies.testing()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).first, 'wrong-pass');
    await tester.pump();
    await tester.tap(find.text('解锁'));
    await tester.pumpAndSettle();

    expect(find.text('密码错误，请重新输入'), findsOneWidget);
    expect(find.text('钱包'), findsNothing);
  });

  testWidgets('shows phase 1 wallet navigation and home actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      WalletApp(dependencies: WalletAppDependencies.testing()),
    );
    await tester.pumpAndSettle();
    await unlockApp(tester);

    // Default tab is Home - check new home content
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('Primary Market Financing Protocol'), findsOneWidget);
    expect(find.text('Capital'), findsOneWidget);
    expect(find.text('Club'), findsOneWidget);
    expect(find.text('Research'), findsOneWidget);
    expect(find.text('预测市场'), findsOneWidget);

    await tester.tap(find.text('预测市场'));
    await tester.pumpAndSettle();
    expect(find.text('阿根廷夺冠'), findsOneWidget);
    expect(find.text('法国进入决赛'), findsOneWidget);
    expect(find.text('巴西小组第一'), findsOneWidget);

    await tester.tap(find.text('Capital'));
    await tester.pumpAndSettle();
    expect(find.text('Alpha funding and lending'), findsOneWidget);
    expect(find.text('Mint USDS'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Tap on wallet tab
    await tester.tap(find.text('钱包'));
    await tester.pumpAndSettle();

    expect(find.text('钱包'), findsOneWidget);
    expect(find.text('记录'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('Across visible networks'), findsOneWidget);
    expect(find.text('Send'), findsOneWidget);
    expect(find.text('Receive'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('DAPP'), findsOneWidget);

    expect(find.textContaining('Swap'), findsNothing);
    expect(find.textContaining('Bridge'), findsNothing);
    expect(find.textContaining('DApp'), findsNothing);
    expect(find.textContaining('NFT'), findsNothing);
  });

  testWidgets('activity tab exposes secondary activity sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      WalletApp(dependencies: WalletAppDependencies.testing()),
    );
    await tester.pumpAndSettle();
    await unlockApp(tester);

    await tester.tap(find.text('记录'));
    await tester.pumpAndSettle();

    expect(find.text('活动'), findsOneWidget);
    for (final label in ['交易', '转账']) {
      expect(find.text(label), findsWidgets);
    }
    for (final label in ['投资', '预测']) {
      expect(find.text(label), findsNothing);
    }
    for (final label in [
      'All',
      'Send',
      'Receive',
      'Pending',
      'Failed',
      'Signature',
      'Approval',
    ]) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('热门网络'), findsNothing);
    expect(find.text('Send ETH'), findsOneWidget);
  });

  testWidgets('me tab exposes settings center', (tester) async {
    await tester.pumpWidget(
      WalletApp(dependencies: WalletAppDependencies.testing()),
    );
    await tester.pumpAndSettle();
    await unlockApp(tester);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();

    expect(find.text('钱包管理'), findsWidgets);
    expect(find.text('网络管理'), findsWidgets);
    expect(find.text('安全与隐私'), findsWidgets);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('授权管理'), findsWidgets);
    expect(find.text('推荐好友'), findsWidgets);
    expect(find.text('通知设置'), findsOneWidget);
    expect(find.text('帮助中心'), findsOneWidget);
  });
}
