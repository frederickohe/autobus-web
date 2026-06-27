import 'package:autobus/barrel.dart';
import 'package:autobus/features/reports/report_details.dart';
import 'package:autobus/features/reports/report_period.dart';
import 'package:autobus/features/reports/reports_overview.dart';
import 'package:autobus/features/reports/reports_snapshot.dart';

class ManageReports extends StatefulWidget {
  const ManageReports({super.key});

  @override
  State<ManageReports> createState() => _ManageReportsState();
}

class _ManageReportsState extends State<ManageReports> {
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
    final snap = _snapshot;

    return Scaffold(
      backgroundColor: ManageScreenStyle.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: ManageScreenStyle.bodyDecoration(),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: SizedBox(
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Analytics',
                            textAlign: TextAlign.center,
                            style: ManageScreenStyle.headerTitleStyle(context),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ManageScreenChrome.hideHeaderBack(context)
                              ? const SizedBox.shrink()
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ManageScreenBackButton(),
                                    SizedBox(width: 18),
                                  ],
                                ),
                        ),
                        if (!_loading)
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: _load,
                              icon: Icon(
                                Icons.refresh,
                                color: ManageScreenStyle.useLightTheme
                                    ? ManageScreenStyle.lightSecondaryText
                                    : Colors.white70,
                              ),
                              tooltip: 'Refresh',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ReportsPeriodSelector(
                  selected: _period,
                  onSelected: _onPeriodChanged,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: AutobusLoadingIndicator(),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF7B4BB7),
                          onRefresh: _load,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_loadError != null) ...[
                                  ReportsErrorBanner(message: _loadError!),
                                  const SizedBox(height: 16),
                                ],
                                if (snap != null) ...[
                                  ReportsOverviewSection(snapshot: snap),
                                  const SizedBox(height: 28),
                                  Text(
                                    'Detailed reports',
                                    style: ManageScreenStyle.hubSectionTitleStyle(),
                                  ),
                                  const SizedBox(height: 16),
                                  ManageHubGrid(
                                    children: [
                                      ManageHubActionCard(
                                        icon: Icons.payments_outlined,
                                        label: 'Financial',
                                        subtitle: formatReportCurrency(
                                          snap.financialVolume,
                                        ),
                                        onTap: () => Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                FinancialReportDetail(
                                                  snapshot: snap,
                                                ),
                                          ),
                                        ),
                                      ),
                                      ManageHubActionCard(
                                        icon: Icons.receipt_long_outlined,
                                        label: 'Orders',
                                        subtitle:
                                            '${snap.filteredOrders.length} orders',
                                        onTap: () => Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (_) => OrdersReportDetail(
                                              snapshot: snap,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ManageHubActionCard(
                                        icon: Icons.request_quote_outlined,
                                        label: 'Invoices',
                                        subtitle: snap.orderInvoicesSent > 0
                                            ? '${snap.orderInvoicesSent} sent · ${snap.paidOrderInvoices} paid'
                                            : 'No invoices yet',
                                        onTap: () => Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                OrderInvoicesReportDetail(
                                                  snapshot: snap,
                                                ),
                                          ),
                                        ),
                                      ),
                                      ManageHubActionCard(
                                        icon: Icons.inventory_2_outlined,
                                        label: 'Inventory',
                                        subtitle:
                                            '${snap.lowStock.length} low stock',
                                        onTap: () => Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                OperationsReportDetail(
                                                  snapshot: snap,
                                                ),
                                          ),
                                        ),
                                      ),
                                      ManageHubActionCard(
                                        icon: Icons.forum_outlined,
                                        label: 'Engagement',
                                        subtitle:
                                            '${snap.conversationsNonIntervention + snap.conversationsActive} chats',
                                        onTap: () => Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                EngagementReportDetail(
                                                  snapshot: snap,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
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
