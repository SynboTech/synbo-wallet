import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';

class MnemonicVerifyPage extends StatefulWidget {
  const MnemonicVerifyPage({super.key, required this.words});

  final List<String> words;

  @override
  State<MnemonicVerifyPage> createState() => _MnemonicVerifyPageState();
}

class _MnemonicVerifyPageState extends State<MnemonicVerifyPage> {
  final _controller = TextEditingController();

  int get _verificationIndex =>
      widget.words.length >= 11 ? 10 : widget.words.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelIndex = _verificationIndex + 1;
    return Scaffold(
      appBar: AppBar(title: const Text('助记词验证')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Word $labelIndex',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Recovery word',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _verify,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Verify'),
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

  void _verify() {
    final ok =
        widget.words.isNotEmpty &&
        _controller.text.trim().toLowerCase() ==
            widget.words[_verificationIndex].toLowerCase();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Backup verified' : 'Incorrect word')),
    );
    if (ok) {
      Navigator.of(context).pop();
    }
  }
}
