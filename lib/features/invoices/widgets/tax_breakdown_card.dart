import 'package:flutter/material.dart';

class TaxBreakdownCard extends StatelessWidget {
  final double subtotal;
  final double discountAmount;
  final String? discountCode;
  final double taxableAmount;
  final bool isInterState;
  final double cgstRate;
  final double cgstAmount;
  final double sgstRate;
  final double sgstAmount;
  final double igstRate;
  final double igstAmount;
  final double totalTax;
  final double totalAmount;
  final String customerState;
  final String companyState;

  const TaxBreakdownCard({
    super.key,
    required this.subtotal,
    this.discountAmount = 0.0,
    this.discountCode,
    required this.taxableAmount,
    required this.isInterState,
    required this.cgstRate,
    required this.cgstAmount,
    required this.sgstRate,
    required this.sgstAmount,
    required this.igstRate,
    required this.igstAmount,
    required this.totalTax,
    required this.totalAmount,
    this.customerState = 'Kerala',
    this.companyState = 'Kerala',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax & Amount Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isInterState ? Colors.indigo.shade50 : Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isInterState ? Colors.indigo.shade200 : Colors.teal.shade200,
                    ),
                  ),
                  child: Text(
                    isInterState ? 'Inter-State (IGST)' : 'Intra-State (CGST+SGST)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isInterState ? Colors.indigo.shade800 : Colors.teal.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Seller State: $companyState | Buyer State: $customerState',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const Divider(height: 24),
            _buildRow('Subtotal', 'Rs. ${subtotal.toStringAsFixed(2)}'),
            if (discountAmount > 0) ...[
              const SizedBox(height: 8),
              _buildRow(
                'Discount ${discountCode != null ? "($discountCode)" : ""}',
                '- Rs. ${discountAmount.toStringAsFixed(2)}',
                valueColor: Colors.green.shade700,
              ),
            ],
            const SizedBox(height: 8),
            _buildRow(
              'Taxable Amount',
              'Rs. ${taxableAmount.toStringAsFixed(2)}',
              isBold: true,
            ),
            const Divider(height: 20),
            if (!isInterState) ...[
              _buildRow(
                'CGST (${cgstRate.toStringAsFixed(1)}%)',
                'Rs. ${cgstAmount.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
              _buildRow(
                'SGST (${sgstRate.toStringAsFixed(1)}%)',
                'Rs. ${sgstAmount.toStringAsFixed(2)}',
              ),
            ] else ...[
              _buildRow(
                'IGST (${igstRate.toStringAsFixed(1)}%)',
                'Rs. ${igstAmount.toStringAsFixed(2)}',
              ),
            ],
            const SizedBox(height: 8),
            _buildRow(
              'Total Tax',
              'Rs. ${totalTax.toStringAsFixed(2)}',
              valueColor: Colors.deepOrange.shade800,
            ),
            const Divider(height: 24, thickness: 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Final Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rs. ${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
