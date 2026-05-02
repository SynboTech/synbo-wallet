import 'package:flutter/material.dart';

import '../../../shared/widgets/risk_banner.dart';
import '../models/allowance_models.dart';

/// Approval 确认页面
/// 显示授权交易的详细信息并要求用户确认
class ApprovalConfirmationPage extends StatelessWidget {
  const ApprovalConfirmationPage({
    super.key,
    required this.pendingApproval,
    required this.onConfirm,
    required this.onCancel,
  });

  final PendingApproval pendingApproval;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final request = pendingApproval.allowanceRequest;
    final token = request.token;

    return Scaffold(
      appBar: AppBar(
        title: Text(pendingApproval.isRevoke ? 'Revoke Approval' : 'Approve'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: onCancel),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTokenInfo(token),
                  const SizedBox(height: 24),
                  _buildTransactionDetails(request, token),
                  const SizedBox(height: 16),
                  RiskBanner(message: pendingApproval.riskWarning),
                ],
              ),
            ),
          ),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildTokenInfo(TokenAllowance token) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Text(
                  token.tokenSymbol.isNotEmpty ? token.tokenSymbol[0] : '?',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    token.tokenSymbol,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    token.tokenContract.hex,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetails(
    AllowanceRequest request,
    TokenAllowance token,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Type',
              pendingApproval.isRevoke ? 'Revoke Approval' : 'Approve',
            ),
            _buildDetailRow('Token', token.tokenSymbol),
            _buildDetailRow('Spender', _truncateAddress(request.spender.hex)),
            _buildDetailRow(
              'Amount',
              request.amountText,
              valueStyle: TextStyle(
                color: request.isUnlimited ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 32),
            _buildDetailRow('Network', pendingApproval.network.name),
            _buildDetailRow(
              'Gas Price',
              pendingApproval.gasEstimate.formattedGasPrice,
            ),
            _buildDetailRow(
              'Estimated Fee',
              pendingApproval.gasEstimate.formattedFee,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  pendingApproval.isRevoke
                      ? 'Confirm Revoke'
                      : 'Confirm Approve',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
