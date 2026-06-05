import 'package:autobus/barrel.dart';
import 'package:autobus/features/reports/report_period.dart';
import 'package:autobus/features/reports/reports_snapshot.dart';

class _ReportDetailScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const _ReportDetailScaffold({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: ManageScreenStyle.homeDashboardBodyDecoration,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      const ManageScreenBackButton(),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          title,
                          style: ManageScreenStyle.headerTitleStyle(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF3F1163)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 13),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;

  const _ListTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF3F1163)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: GoogleFonts.montserrat(
              color: const Color(0xFFB794F6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class FinancialReportDetail extends StatelessWidget {
  final ReportsSnapshot snapshot;

  const FinancialReportDetail({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final items = snapshot.filteredFinancials;
    final byCategory = <String, double>{};
    for (final t in items) {
      final cat = (t['category'] ?? t['transaction_type'] ?? 'Other')
          .toString();
      byCategory[cat] = (byCategory[cat] ?? 0) + asReportDouble(t['amount']);
    }

    return _ReportDetailScaffold(
      title: 'Financial report',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            snapshot.period.label,
            style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          _StatRow(
            label: 'Payment revenue',
            value: formatReportCurrency(snapshot.revenue),
          ),
          _StatRow(
            label: 'Transaction volume',
            value: formatReportCurrency(snapshot.financialVolume),
          ),
          _StatRow(label: 'Total transactions', value: '${items.length}'),
          _StatRow(
            label: 'Completed',
            value: '${snapshot.completedTransactions}',
          ),
          _StatRow(label: 'Pending', value: '${snapshot.pendingTransactions}'),
          _StatRow(label: 'Failed', value: '${snapshot.failedTransactions}'),
          if (byCategory.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'By category',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...byCategory.entries.map(
              (e) =>
                  _StatRow(label: e.key, value: formatReportCurrency(e.value)),
            ),
          ],
          if (items.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Recent transactions',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...items.take(15).map((t) {
              final desc =
                  (t['description'] ??
                          t['intent'] ??
                          t['transaction_type'] ??
                          'Transaction')
                      .toString();
              final status = (t['status'] ?? '').toString();
              return _ListTile(
                title: desc,
                subtitle: status,
                trailing: formatReportCurrency(asReportDouble(t['amount'])),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class OrdersReportDetail extends StatelessWidget {
  final ReportsSnapshot snapshot;

  const OrdersReportDetail({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final orders = snapshot.filteredOrders;
    final statuses = <String, int>{};
    for (final o in orders) {
      final s = (o['order_status'] ?? 'unknown').toString();
      statuses[s] = (statuses[s] ?? 0) + 1;
    }

    return _ReportDetailScaffold(
      title: 'Orders report',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            snapshot.period.label,
            style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          _StatRow(label: 'Total orders', value: '${orders.length}'),
          _StatRow(
            label: 'Total value',
            value: formatReportCurrency(snapshot.ordersValue),
          ),
          _StatRow(
            label: 'Invoices sent',
            value: '${snapshot.orderInvoicesSent}',
          ),
          _StatRow(
            label: 'Invoices paid',
            value: '${snapshot.paidOrderInvoices}',
          ),
          _StatRow(
            label: 'Invoiced amount',
            value: formatReportCurrency(snapshot.orderInvoicesValue),
          ),
          ...statuses.entries.map(
            (e) => _StatRow(label: e.key, value: '${e.value}'),
          ),
          if (orders.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Recent orders',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...orders.take(20).map((o) {
              final name = (o['item_name'] ?? o['order_number'] ?? 'Order')
                  .toString();
              final status = (o['order_status'] ?? '').toString();
              return _ListTile(
                title: name,
                subtitle: status,
                trailing: formatReportCurrency(
                  asReportDouble(o['total_amount']),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class OrderInvoicesReportDetail extends StatelessWidget {
  final ReportsSnapshot snapshot;

  const OrderInvoicesReportDetail({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final invoices = snapshot.recentOrderInvoices;

    return _ReportDetailScaffold(
      title: 'Order invoices',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            snapshot.period.label,
            style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          _StatRow(
            label: 'Invoices sent',
            value: '${snapshot.orderInvoicesSent}',
          ),
          _StatRow(label: 'Paid', value: '${snapshot.paidOrderInvoices}'),
          _StatRow(
            label: 'Pending',
            value: '${snapshot.pendingOrderInvoices}',
          ),
          _StatRow(
            label: 'Failed',
            value: '${snapshot.failedOrderInvoices}',
          ),
          _StatRow(
            label: 'Total invoiced',
            value: formatReportCurrency(snapshot.orderInvoicesValue),
          ),
          _StatRow(
            label: 'Collected',
            value: formatReportCurrency(snapshot.paidOrderInvoicesValue),
          ),
          if (invoices.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Recent invoices',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...invoices.take(20).map((inv) {
              final orderLabel =
                  snapshot.orderNumberForBilling(inv) ??
                  (inv['description'] ?? 'Order invoice').toString();
              final status = (inv['status'] ?? '').toString();
              final ref = (inv['reference'] ?? '').toString();
              return _ListTile(
                title: orderLabel,
                subtitle: ref.isEmpty ? status : '$status · $ref',
                trailing: formatReportCurrency(asReportDouble(inv['amount'])),
              );
            }),
          ] else ...[
            const SizedBox(height: 24),
            Text(
              'No Paystack invoices were sent for orders in this period. '
              'Use “Send invoice” on an order to generate a payment link for your customer.',
              style: GoogleFonts.montserrat(
                color: Colors.white38,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OperationsReportDetail extends StatelessWidget {
  final ReportsSnapshot snapshot;

  const OperationsReportDetail({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final products = snapshot.products;
    final lowStock = snapshot.lowStock;

    return _ReportDetailScaffold(
      title: 'Inventory report',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            snapshot.period.label,
            style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          _StatRow(label: 'Products in catalogue', value: '${products.length}'),
          _StatRow(label: 'Low-stock items', value: '${lowStock.length}'),
          if (lowStock.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Low stock alert',
              style: GoogleFonts.montserrat(
                color: const Color(0xFFE6A23C),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...lowStock.map((inv) {
              final name =
                  (inv['product_name'] ??
                          inv['name'] ??
                          inv['inventory_id'] ??
                          'Item')
                      .toString();
              final qty = inv['quantity'] ?? inv['stock_quantity'] ?? '—';
              return _ListTile(
                title: name,
                subtitle: 'Qty: $qty',
                trailing: (inv['status'] ?? 'low').toString(),
              );
            }),
          ],
          if (products.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Products',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...products.take(20).map((p) {
              final name = (p['name'] ?? p['product_name'] ?? 'Product')
                  .toString();
              final category = (p['category'] ?? '').toString();
              final price = p['price'] ?? p['unit_price'];
              return _ListTile(
                title: name,
                subtitle: category.isEmpty ? '—' : category,
                trailing: price != null
                    ? formatReportCurrency(asReportDouble(price))
                    : '—',
              );
            }),
          ],
        ],
      ),
    );
  }
}

class EngagementReportDetail extends StatelessWidget {
  final ReportsSnapshot snapshot;

  const EngagementReportDetail({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return _ReportDetailScaffold(
      title: 'Engagement report',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            snapshot.period.label,
            style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          _StatRow(
            label: 'Completed conversations',
            value: '${snapshot.conversationsCompleted}',
          ),
          _StatRow(
            label: 'Active interventions',
            value: '${snapshot.conversationsActive}',
          ),
          _StatRow(
            label: 'Human handovers',
            value: '${snapshot.interventions}',
          ),
          _StatRow(
            label: 'Marketing assets',
            value: '${snapshot.marketingAssets}',
          ),
          _StatRow(
            label: 'Emails sent (recent)',
            value: '${snapshot.sentEmails}',
          ),
          const SizedBox(height: 24),
          Text(
            'Data sources',
            style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Conversations and interventions from /conversations/me and /interventions/list. Marketing from /social/digital-marketing/assets. Emails from /user/me/emails/sent.',
            style: GoogleFonts.montserrat(
              color: Colors.white38,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
