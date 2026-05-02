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
  String? _generatedMnemonic;

  List<String> get _generatedWords => (_generatedMnemonic ?? '')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    if (widget.mode == WalletSetupMode.create) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final mnemonic = await context.walletState.generateRecoveryPhrase();
        if (!mounted) {
          return;
        }
        setState(() => _generatedMnemonic = mnemonic);
      });
    }
  }

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
          if (_generatedMnemonic == null)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _generatedWords.length; i++)
                  Chip(label: Text('${i + 1}. ${_generatedWords[i]}')),
              ],
            ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _generatedMnemonic == null
                  ? null
                  : () => setState(() => _step = 2),
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
            'Verify recovery word',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _verifyController,
            decoration: InputDecoration(
              labelText: _generatedWords.isEmpty
                  ? 'Recovery word'
                  : 'Word ${(_generatedWords.length >= 11 ? 11 : _generatedWords.length)}',
            ),
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
                if (!context.walletState.isValidRecoveryPhrase(
                  _mnemonicController.text,
                )) {
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

  Future<void> _finishCreate() async {
    final verificationIndex = _generatedWords.length >= 11
        ? 10
        : _generatedWords.length - 1;
    if (_generatedWords.isEmpty ||
        _verifyController.text.trim().toLowerCase() !=
            _generatedWords[verificationIndex]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification word is incorrect')),
      );
      return;
    }
    final state = context.walletState;
    await state.createWallet(
      name: _walletNameController.text,
      mnemonic: _generatedMnemonic ?? '',
    );
    await state.configurePassword(_passwordController.text);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _finishImport() async {
    final state = context.walletState;
    await state.importWallet(
      name: _walletNameController.text,
      mnemonic: _mnemonicController.text,
    );
    await state.configurePassword(_passwordController.text);
    if (!mounted) {
      return;
    }
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
