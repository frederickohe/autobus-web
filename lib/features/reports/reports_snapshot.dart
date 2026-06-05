import 'package:autobus/features/reports/report_period.dart';

class ReportsSnapshot {
  final ReportPeriod period;
  final double revenue;
  final List<Map<String, dynamic>> financials;
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> billings;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> lowStock;
  /// Sessions with conversation_lifecycle == completed (subset of listed history).
  final int conversationsCompleted;
  /// Count from API `completed` (all sessions without active intervention).
  final int conversationsNonIntervention;
  final int conversationsActive;
  final int interventions;
  final int marketingAssets;
  final int sentEmails;
  final String? error;

  const ReportsSnapshot({
    required this.period,
    this.revenue = 0,
    this.financials = const [],
    this.orders = const [],
    this.billings = const [],
    this.products = const [],
    this.lowStock = const [],
    this.conversationsCompleted = 0,
    this.conversationsNonIntervention = 0,
    this.conversationsActive = 0,
    this.interventions = 0,
    this.marketingAssets = 0,
    this.sentEmails = 0,
    this.error,
  });

  List<Map<String, dynamic>> get filteredFinancials => financials
      .where((t) => period.includes(ReportPeriod.parseDate(t['created_at'])))
      .toList();

  List<Map<String, dynamic>> get filteredOrders => orders
      .where(
        (o) => period.includes(
          ReportPeriod.parseDate(o['order_date'] ?? o['created_at']),
        ),
      )
      .toList();

  int countOrdersByStatus(String status) => filteredOrders
      .where(
        (o) =>
            (o['order_status'] ?? '').toString().toLowerCase() ==
            status.toLowerCase(),
      )
      .length;

  double get ordersValue => filteredOrders.fold<double>(
    0,
    (sum, o) => sum + asReportDouble(o['total_amount']),
  );

  double get financialVolume => filteredFinancials.fold<double>(
    0,
    (sum, t) => sum + asReportDouble(t['amount']),
  );

  int get completedTransactions => filteredFinancials
      .where((t) => (t['status'] ?? '').toString().toLowerCase() == 'completed')
      .length;

  int get pendingTransactions => filteredFinancials
      .where((t) => (t['status'] ?? '').toString().toLowerCase() == 'pending')
      .length;

  int get failedTransactions => filteredFinancials
      .where((t) => (t['status'] ?? '').toString().toLowerCase() == 'failed')
      .length;

  Set<String> get _orderIdsInPeriod => filteredOrders
      .map((o) => (o['order_id'] ?? '').toString())
      .where((id) => id.isNotEmpty)
      .toSet();

  /// Paystack order invoices (billing charges linked to merchant orders).
  List<Map<String, dynamic>> get filteredOrderBillings {
    final orderIds = _orderIdsInPeriod;
    return billings.where((b) {
      if (!_isOrderBilling(b)) return false;
      if (!period.includes(ReportPeriod.parseDate(b['created_on']))) {
        return false;
      }
      final externalId = (b['external_id'] ?? '').toString();
      if (orderIds.isEmpty) return true;
      return externalId.isEmpty || orderIds.contains(externalId);
    }).toList();
  }

  static bool _isOrderBilling(Map<String, dynamic> b) =>
      (b['source_type'] ?? '').toString().toUpperCase() == 'ORDER';

  int get orderInvoicesSent {
    if (filteredOrderBillings.isNotEmpty) {
      return filteredOrderBillings.length;
    }
    return filteredOrders.where(_orderHasInvoice).length;
  }

  static bool _orderHasInvoice(Map<String, dynamic> o) {
    final ref = (o['payment_reference'] ?? '').toString();
    if (ref.isNotEmpty) return true;
    final details = o['payment_details'];
    if (details is Map && details.isNotEmpty) return true;
    return false;
  }

  int countOrderInvoicesByStatus(String status) => filteredOrderBillings
      .where(
        (b) =>
            (b['status'] ?? '').toString().toUpperCase() ==
            status.toUpperCase(),
      )
      .length;

  int get paidOrderInvoices => countOrderInvoicesByStatus('PAID');

  int get pendingOrderInvoices => countOrderInvoicesByStatus('PENDING');

  int get failedOrderInvoices => countOrderInvoicesByStatus('FAILED');

  double get orderInvoicesValue => filteredOrderBillings.fold<double>(
    0,
    (sum, b) => sum + asReportDouble(b['amount']),
  );

  double get paidOrderInvoicesValue => filteredOrderBillings
      .where(
        (b) => (b['status'] ?? '').toString().toUpperCase() == 'PAID',
      )
      .fold<double>(0, (sum, b) => sum + asReportDouble(b['amount']));

  List<Map<String, dynamic>> get recentOrderInvoices {
    final sorted = List<Map<String, dynamic>>.from(filteredOrderBillings);
    sorted.sort((a, b) {
      final da = ReportPeriod.parseDate(a['created_on']);
      final db = ReportPeriod.parseDate(b['created_on']);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    return sorted;
  }

  String? orderNumberForBilling(Map<String, dynamic> billing) {
    final meta = billing['metadata'];
    if (meta is Map && meta['order_number'] != null) {
      return meta['order_number'].toString();
    }
    final orderId = (billing['external_id'] ?? '').toString();
    if (orderId.isEmpty) return null;
    for (final o in filteredOrders) {
      if ((o['order_id'] ?? '').toString() == orderId) {
        return (o['order_number'] ?? o['order_id']).toString();
      }
    }
    return orderId;
  }
}

double asReportDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}
