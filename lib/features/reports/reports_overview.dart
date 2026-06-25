import 'package:autobus/barrel.dart';
import 'package:autobus/features/reports/report_period.dart';
import 'package:autobus/features/reports/reports_snapshot.dart';

Future<ReportsSnapshot> loadReportsSnapshot(
  ApiService api,
  ReportPeriod period,
) async {
  final results = await Future.wait<dynamic>([
    api.getRevenueByTimeline(period.apiValue),
    api.getFinancials(page: 1, pageSize: 200),
    api.listOrders(skip: 0, limit: 200),
    api.listBillings(page: 0, size: 200),
    api.listProducts(skip: 0, limit: 200),
    api.getLowStockInventory(),
    api.listMyConversations(skip: 0, limit: 100),
    api.listInterventions(limit: 100),
    api.listDigitalMarketingAssets(limit: 50, offset: 0),
    api.getMySentEmails(limit: 50),
  ]);

  final conversations = results[6] as Map<String, List<Map<String, dynamic>>>;
  final marketing = results[8] as Map<String, dynamic>;
  final emails = results[9] as Map<String, dynamic>;
  final interventions = results[7] as List<Map<String, dynamic>>;

  final completedList = conversations['completed'] ?? const [];
  final completedLifecycleCount = completedList
      .where(
        (c) => (c['conversation_lifecycle'] ?? '').toString() == 'completed',
      )
      .length;

  return ReportsSnapshot(
    period: period,
    revenue: results[0] as double,
    financials: results[1] as List<Map<String, dynamic>>,
    orders: results[2] as List<Map<String, dynamic>>,
    billings: results[3] as List<Map<String, dynamic>>,
    products: results[4] as List<Map<String, dynamic>>,
    lowStock: results[5] as List<Map<String, dynamic>>,
    conversationsCompleted: completedLifecycleCount,
    conversationsNonIntervention: completedList.length,
    conversationsActive: conversations['intervention_active']?.length ?? 0,
    interventions: interventions.length,
    marketingAssets:
        (marketing['total'] as num?)?.toInt() ??
        (marketing['items'] as List?)?.length ??
        0,
    sentEmails:
        (emails['total_returned'] as num?)?.toInt() ??
        (emails['emails'] as List?)?.length ??
        0,
  );
}

class ReportsOverviewPanel extends StatefulWidget {
  const ReportsOverviewPanel({
    super.key,
    this.showPeriodSelector = true,
    this.showViewDetailedReportsLink = false,
    this.onViewDetailedReports,
    this.horizontalPadding = 0,
  });

  final bool showPeriodSelector;
  final bool showViewDetailedReportsLink;
  final VoidCallback? onViewDetailedReports;
  final double horizontalPadding;

  @override
  State<ReportsOverviewPanel> createState() => _ReportsOverviewPanelState();
}

class _ReportsOverviewPanelState extends State<ReportsOverviewPanel> {
  ReportPeriod _period = ReportPeriod.thisMonth;
  ReportsSnapshot? _snapshot;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final snapshot = await loadReportsSnapshot(
        context.read<ApiService>(),
        _period,
      );
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
        _snapshot = ReportsSnapshot(period: _period, error: _loadError);
      });
    }
  }

  void _onPeriodChanged(ReportPeriod period) {
    if (_period == period) return;
    setState(() => _period = period);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.horizontalPadding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showPeriodSelector) ...[
          ReportsPeriodSelector(
            selected: _period,
            onSelected: _onPeriodChanged,
            horizontalPadding: horizontalPadding,
          ),
          const SizedBox(height: 16),
        ],
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: AutobusLoadingIndicator()),
          )
        else ...[
          if (_loadError != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ReportsErrorBanner(message: _loadError!),
            ),
            const SizedBox(height: 16),
          ],
          if (_snapshot case final snap?) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ReportsOverviewSection(snapshot: snap),
            ),
            if (widget.showViewDetailedReportsLink &&
                widget.onViewDetailedReports != null) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: widget.onViewDetailedReports,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View detailed reports'),
                  style: TextButton.styleFrom(
                    foregroundColor: CustColors.mainCol,
                  ),
                ),
              ),
            ],
          ],
        ],
      ],
    );
  }
}

class ReportsPeriodSelector extends StatelessWidget {
  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onSelected;
  final double horizontalPadding;

  const ReportsPeriodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.horizontalPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: ReportPeriod.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final period = ReportPeriod.values[index];
          final isSelected = period == selected;
          return FilterChip(
            label: Text(period.label),
            selected: isSelected,
            onSelected: (_) => onSelected(period),
            labelStyle: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            selectedColor: const Color(0xFF5A2D82),
            backgroundColor: const Color(0xFF1A0F2E),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF7B4BB7)
                  : const Color(0xFF3F1163),
            ),
            checkmarkColor: Colors.white,
            showCheckmark: false,
          );
        },
      ),
    );
  }
}

class ReportsOverviewSection extends StatelessWidget {
  final ReportsSnapshot snapshot;

  const ReportsOverviewSection({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final snap = snapshot;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Overview · ${snap.period.label}',
          style: ManageScreenStyle.hubSectionTitleStyle(),
        ),
        const SizedBox(height: 16),
        ReportsHeroMetricCard(
          label: 'Revenue',
          value: formatReportCurrency(snap.revenue),
          icon: Icons.trending_up,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReportsMetricTile(
                label: 'Order value',
                value: formatReportCurrency(snap.ordersValue),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportsMetricTile(
                label: 'Transactions',
                value: '${snap.filteredFinancials.length}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReportsMetricTile(
                label: 'Orders',
                value: '${snap.filteredOrders.length}',
                sub: '${snap.countOrdersByStatus('completed')} done',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportsMetricTile(
                label: 'Products',
                value: '${snap.products.length}',
                sub: '${snap.lowStock.length} low stock',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReportsMetricTile(
                label: 'Completed txns',
                value: '${snap.completedTransactions}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportsMetricTile(
                label: 'Pending / failed',
                value:
                    '${snap.pendingTransactions} / ${snap.failedTransactions}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ReportsMetricTile(
                label: 'Order invoices',
                value: '${snap.orderInvoicesSent}',
                sub: '${snap.paidOrderInvoices} paid',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ReportsMetricTile(
                label: 'Invoiced value',
                value: formatReportCurrency(snap.orderInvoicesValue),
                sub:
                    '${formatReportCurrency(snap.paidOrderInvoicesValue)} collected',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ReportsHeroMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ReportsHeroMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F1163), Color(0xFF1E0C37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5A2D82)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB794F6), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
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

class ReportsMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;

  const ReportsMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final light = ManageScreenStyle.useLightTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: light ? Colors.white : null,
        border: Border.all(
          color: light ? ManageScreenStyle.lightBorder : const Color(0xFF3F1163),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: light
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: light
                  ? ManageScreenStyle.lightSecondaryText
                  : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.montserrat(
              color: light ? ManageScreenStyle.lightPrimaryText : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(
              sub!,
              style: GoogleFonts.montserrat(
                color: light
                    ? ManageScreenStyle.lightSecondaryText
                    : Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ReportsErrorBanner extends StatelessWidget {
  final String message;

  const ReportsErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3D1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE63946).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFE63946),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.montserrat(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
