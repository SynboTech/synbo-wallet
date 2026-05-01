String compactAddress(String address) {
  if (address.length <= 14) {
    return address;
  }
  return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
}

String formatCurrency(double value) {
  final fixed = value.abs() >= 1000
      ? value.toStringAsFixed(2)
      : value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final buffer = StringBuffer();
  for (var i = 0; i < parts.first.length; i++) {
    final remaining = parts.first.length - i;
    buffer.write(parts.first[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }
  return '\$${buffer.toString()}.${parts.last}';
}

String formatTokenAmount(double value) {
  if (value == 0) {
    return '0';
  }
  if (value.abs() >= 100) {
    return value.toStringAsFixed(2);
  }
  if (value.abs() >= 1) {
    return value.toStringAsFixed(4);
  }
  return value.toStringAsFixed(6);
}

String formatDateTime(DateTime value) {
  final local = value.toLocal();
  String two(int input) => input.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}
