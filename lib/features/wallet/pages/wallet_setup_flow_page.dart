import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/risk_banner.dart';
import '../models/wallet_models.dart';
import '../providers/wallet_state_scope.dart';

class WalletSetupFlowPage extends StatefulWidget {
  const WalletSetupFlowPage({super.key, required this.mode});

  final WalletSetupMode mode;

  @override
  State<WalletSetupFlowPage> createState() => _WalletSetupFlowPageState();
}

class _WalletSetupFlowPageState extends State<WalletSetupFlowPage> {
  final _walletNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _mnemonicController = TextEditingController();
  final _verifyController = TextEditingController();
  int _step = 0;

  static const _mnemonic = [
    'river',
    'silver',
    'orbit',
    'fabric',
    'cactus',
    'lunar',
    'velvet',
    'harbor',
    'matrix',
    'signal',
    'ocean',
    'anchor',
  ];

  @override
  void dispose() {
    _walletNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mnemonicController.dispose();
    _verifyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.mode == WalletSetupMode.create;
    return Scaffold(
      appBar: AppBar(title: Text(isCreate ? '创建钱包' : '导入钱包')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StepHeader(step: _step, total: 3),
            const SizedBox(height: 14),
            AppCard(
              child: isCreate
                  ? _buildCreateStep(context)
                  : _buildImportStep(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateStep(BuildContext context) {
    return switch (_step) {
      0 => _PasswordStep(
        walletNameController: _walletNameController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        onNext: _validatePasswordAndNext,
      ),
      1 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RiskBanner(
            message:
                'Write down the recovery phrase in order and keep it offline. Anyone with this phrase can control the wallet.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _mnemonic.length; i++)
                Chip(label: Text('${i + 1}. ${_mnemonic[i]}')),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => setState(() => _step = 2),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('I Backed It Up'),
            ),
          ),
        ],
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify word 11',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _verifyController,
            decoration: const InputDecoration(labelText: 'Word 11'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _finishCreate,
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Create Wallet'),
            ),
          ),
        ],
      ),
    };
  }

  Widget _buildImportStep(BuildContext context) {
    return switch (_step) {
      0 => Column(
        children: [
          TextField(
            controller: _walletNameController,
            decoration: const InputDecoration(labelText: 'Wallet Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mnemonicController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Recovery Phrase'),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (_mnemonicController.text
                        .trim()
                        .split(RegExp(r'\s+'))
                        .length <
                    12) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter at least 12 words')),
                  );
                  return;
                }
                setState(() => _step = 1);
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Continue'),
            ),
          ),
        ],
      ),
      1 => _PasswordStep(
        walletNameController: _walletNameController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        onNext: _validatePasswordAndNext,
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to Import',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _finishImport,
              icon: const Icon(Icons.download_done_rounded),
              label: const Text('Import Wallet'),
            ),
          ),
        ],
      ),
    };
  }

  void _validatePasswordAndNext() {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _step += 1);
  }

  void _finishCreate() {
    if (_verifyController.text.trim().toLowerCase() != 'ocean') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification word is incorrect')),
      );
      return;
    }
    context.walletState.createWallet(name: _walletNameController.text);
    Navigator.of(context).pop();
  }

  void _finishImport() {
    context.walletState.importWallet(name: _walletNameController.text);
    Navigator.of(context).pop();
  }
}

class _PasswordStep extends StatelessWidget {
  const _PasswordStep({
    required this.walletNameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onNext,
  });

  final TextEditingController walletNameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: walletNameController,
          decoration: const InputDecoration(labelText: 'Wallet Name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Confirm Password'),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: LinearProgressIndicator(value: (step + 1) / total)),
        const SizedBox(width: 12),
        Text(
          '${step + 1}/$total',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
