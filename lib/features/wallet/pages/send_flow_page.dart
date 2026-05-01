import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../models/wallet_models.dart';
import '../providers/wallet_state_scope.dart';
import 'transaction_confirmation_page.dart';

class SendFlowPage extends StatefulWidget {
  const SendFlowPage({super.key, this.initialTokenId, this.initialRecipient});

  final String? initialTokenId;
  final String? initialRecipient;

  @override
  State<SendFlowPage> createState() => _SendFlowPageState();
}

class _SendFlowPageState extends State<SendFlowPage> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  String? _tokenId;

  @override
  void initState() {
    super.initState();
    _tokenId = widget.initialTokenId;
    _recipientController.text = widget.initialRecipient ?? '';
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    final tokens = state.visibleTokens;
    _tokenId ??= tokens.isNotEmpty ? tokens.first.id : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Send')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _tokenId,
                      decoration: const InputDecoration(
                        labelText: 'Token',
                        prefixIcon: Icon(Icons.toll_outlined),
                      ),
                      items: [
                        for (final token in tokens)
                          DropdownMenuItem(
                            value: token.id,
                            child: Text(
                              '${token.symbol} · ${state.networkById(token.networkId).name}',
                            ),
                          ),
                      ],
                      validator: (value) =>
                          value == null ? 'Select a token' : null,
                      onChanged: (value) => setState(() => _tokenId = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _recipientController,
                      decoration: const InputDecoration(
                        labelText: 'To',
                        prefixIcon: Icon(Icons.call_made_rounded),
                      ),
                      validator: (value) {
                        final input = value?.trim() ?? '';
                        if (!input.startsWith('0x') || input.length < 12) {
                          return 'Enter a valid recipient address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value ?? '');
                        if (amount == null || amount <= 0) {
                          return 'Enter an amount greater than 0';
                        }
                        final token = state.tokenById(_tokenId ?? '');
                        if (token != null && amount > token.balance) {
                          return 'Insufficient balance';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: tokens.isEmpty ? null : _continue,
                        icon: const Icon(Icons.verified_user_outlined),
                        label: const Text('Review Transaction'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final state = context.walletState;
    final token = state.tokenById(_tokenId ?? '');
    if (token == null) {
      return;
    }
    final network = state.networkById(token.networkId);
    final transfer = PendingTransfer(
      from: state.currentAccount.address,
      to: _recipientController.text.trim(),
      network: network,
      token: token,
      amount: double.parse(_amountController.text),
      gasFee: token.symbol == network.nativeSymbol ? 0.0031 : 0.0018,
      riskWarning:
          'Verify the recipient, network, amount, token, gas fee, and total before confirming. Transfers cannot be reversed.',
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionConfirmationPage(transfer: transfer),
      ),
    );
  }
}
