import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

import '../models/allowance_models.dart';
import '../models/wallet_models.dart';

/// Token Allowances 页面
/// 显示所有 ERC20 Token 的授权信息
class TokenAllowancesPage extends StatefulWidget {
  const TokenAllowancesPage({
    super.key,
    required this.allowances,
    required this.networks,
    required this.onApprove,
    required this.onRevoke,
    this.isLoading = false,
  });

  final List<TokenAllowance> allowances;
  final List<ChainNetwork> networks;
  final void Function(
    TokenAllowance token,
    EthereumAddress spender,
    bool isRevoke,
  )
  onApprove;
  final void Function(TokenAllowance token) onRevoke;
  final bool isLoading;

  @override
  State<TokenAllowancesPage> createState() => _TokenAllowancesPageState();
}

class _TokenAllowancesPageState extends State<TokenAllowancesPage> {
  String _searchQuery = '';
  String? _selectedNetworkId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Approvals'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildNetworkFilter(),
          Expanded(
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildAllowancesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by token or spender...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildNetworkFilter() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildNetworkChip('All', null),
          ...widget.networks.map((n) => _buildNetworkChip(n.name, n.id)),
        ],
      ),
    );
  }

  Widget _buildNetworkChip(String label, String? networkId) {
    final isSelected = _selectedNetworkId == networkId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedNetworkId = networkId),
      ),
    );
  }

  Widget _buildAllowancesList() {
    final filtered = _filteredAllowances;
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final allowance = filtered[index];
        return _buildAllowanceCard(allowance);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No approvals found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Your token approvals will appear here',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAllowanceCard(TokenAllowance allowance) {
    final isActive = allowance.hasAllowance;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTokenIcon(allowance.tokenSymbol),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        allowance.tokenSymbol,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        allowance.networkName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(isActive),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Spender', _truncateAddress(allowance.spender.hex)),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Allowance',
              '${allowance.formattedAllowance} ${allowance.tokenSymbol}',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRevokeDialog(allowance),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Revoke'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onApprove(
                      allowance,
                      allowance.spender,
                      isActive,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(isActive ? 'Update' : 'Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenIcon(String symbol) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          symbol.isNotEmpty ? symbol[0] : '?',
          style: TextStyle(
            color: Colors.blue[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _truncateAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  void _showRevokeDialog(TokenAllowance allowance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Approval'),
        content: Text(
          'Are you sure you want to revoke ${_truncateAddress(allowance.spender.hex)}\'s '
          'permission to spend your ${allowance.tokenSymbol}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onRevoke(allowance);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  List<TokenAllowance> get _filteredAllowances {
    return widget.allowances.where((a) {
      // Network filter
      if (_selectedNetworkId != null && a.networkId != _selectedNetworkId) {
        return false;
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return a.tokenSymbol.toLowerCase().contains(query) ||
            a.spender.hex.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }
}
