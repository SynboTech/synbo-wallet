import 'package:flutter/material.dart';

import '../../../shared/widgets/risk_banner.dart';
import '../providers/wallet_state_scope.dart';

class AddTokenPage extends StatefulWidget {
  const AddTokenPage({super.key});

  @override
  State<AddTokenPage> createState() => _AddTokenPageState();
}

class _AddTokenPageState extends State<AddTokenPage> {
  final _formKey = GlobalKey<FormState>();
  final _contractController = TextEditingController();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();

  @override
  void dispose() {
    _contractController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Token')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RiskBanner(
              message:
                  'Only add tokens from contracts you trust. A fake token can be used to mislead approvals or transfers.',
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _contractController,
                    decoration: InputDecoration(
                      labelText: 'Contract Address',
                      helperText: state.currentNetwork.name,
                    ),
                    validator: (value) {
                      final input = value?.trim() ?? '';
                      if (!input.startsWith('0x') || input.length < 12) {
                        return 'Enter a valid contract address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Token Name'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Token name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _symbolController,
                    decoration: const InputDecoration(labelText: 'Symbol'),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Symbol is required'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add Token'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.walletState.addToken(
      name: _nameController.text,
      symbol: _symbolController.text,
      contractAddress: _contractController.text,
    );
    Navigator.of(context).pop();
  }
}
