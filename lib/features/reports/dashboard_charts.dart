import 'dart:math' as math;

import 'package:autobus/barrel.dart';
import 'package:autobus/features/reports/report_period.dart';
import 'package:autobus/features/reports/reports_snapshot.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DashboardAnalyticsSection extends StatelessWidget {
  const DashboardAnalyticsSection({super.key, required this.snapshot});

  final ReportsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QuickStatsRow(snapshot: snapshot),
            const SizedBox(height: 20),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _OrderStatusChart(snapshot: snapshot)),
                  const SizedBox(width: 16),
                  Expanded(child: _ActivityBreakdownChart(snapshot: snapshot)),
                ],
              )
            else ...[
              _OrderStatusChart(snapshot: snapshot),
              const SizedBox(height: 16),
              _ActivityBreakdownChart(snapshot: snapshot),
            ],
            const SizedBox(height: 16),
            _OrdersTrendChart(snapshot: snapshot),
          ],
        );
      },
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.snapshot});

  final ReportsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final snap = snapshot;
    final cards = [
      _QuickStatCard(
        label: 'Orders',
        value: '${snap.filteredOrders.length}',
        sub: formatReportCurrency(snap.ordersValue),
        icon: Icons.shopping_bag_outlined,
        accent: const Color(0xFF7C3AED),
      ),
      _QuickStatCard(
        label: 'Products',
        value: '${snap.products.length}',
        sub: '${snap.lowStock.length} low stock',
        icon: Icons.inventory_2_outlined,
        accent: const Color(0xFF2563EB),
      ),
      _QuickStatCard(
        label: 'Conversations',
        value: '${snap.conversationsNonIntervention}',
        sub: '${snap.conversationsActive} active',
        icon: Icons.forum_outlined,
        accent: const Color(0xFF059669),
      ),
      _QuickStatCard(
        label: 'Outreach',
        value: '${snap.sentEmails + snap.marketingAssets}',
        sub: '${snap.sentEmails} emails · ${snap.marketingAssets} assets',
        icon: Icons.campaign_outlined,
        accent: const Color(0xFFDB2777),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 960
            ? 4
            : constraints.maxWidth >= 560
                ? 2
                : 1;

        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: count == 1 ? 3.2 : 2.1,
          children: cards,
        );
      },
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ManageScreenStyle.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    color: ManageScreenStyle.lightSecondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    color: ManageScreenStyle.lightPrimaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: ManageScreenStyle.lightSecondaryText,
                    fontSize: 10,
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

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ManageScreenStyle.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: ManageScreenStyle.hubSectionTitleStyle()),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _OrderStatusChart extends StatelessWidget {
  const _OrderStatusChart({required this.snapshot});

  final ReportsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final completed = snapshot.countOrdersByStatus('completed');
    final pending = snapshot.countOrdersByStatus('pending');
    final cancelled = snapshot.countOrdersByStatus('cancelled');
    final other = math.max(
      0,
      snapshot.filteredOrders.length - completed - pending - cancelled,
    );
    final total = snapshot.filteredOrders.length;
    final completionRate = total == 0 ? 0.0 : completed / total;

    final segments = [
      _ChartSegment('Completed', completed, const Color(0xFF059669)),
      _ChartSegment('Pending', pending, const Color(0xFFF59E0B)),
      _ChartSegment('Cancelled', cancelled, const Color(0xFFEF4444)),
      if (other > 0)
        _ChartSegment('Other', other, const Color(0xFF94A3B8)),
    ];

    return _ChartCard(
      title: 'Order status',
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 52,
            lineWidth: 10,
            percent: completionRate.clamp(0, 1),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: const Color(0xFF059669),
            backgroundColor: const Color(0xFFE2E8F0),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(completionRate * 100).round()}%',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ManageScreenStyle.lightPrimaryText,
                  ),
                ),
                Text(
                  'done',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: ManageScreenStyle.lightSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                for (final segment in segments) ...[
                  _LegendRow(segment: segment, total: total),
                  if (segment != segments.last) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSegment {
  const _ChartSegment(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.segment, required this.total});

  final _ChartSegment segment;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : ((segment.value / total) * 100).round();

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: segment.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            segment.label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: ManageScreenStyle.lightPrimaryText,
            ),
          ),
        ),
        Text(
          '${segment.value}',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: ManageScreenStyle.lightPrimaryText,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$pct%',
          style: GoogleFonts.montserrat(
            fontSize: 10,
            color: ManageScreenStyle.lightSecondaryText,
          ),
        ),
      ],
    );
  }
}

class _ActivityBreakdownChart extends StatelessWidget {
  const _ActivityBreakdownChart({required this.snapshot});

  final ReportsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final items = [
      _BarItem('Completed chats', snapshot.conversationsCompleted, const Color(0xFF7C3AED)),
      _BarItem('Active chats', snapshot.conversationsActive, const Color(0xFF2563EB)),
      _BarItem('Interventions', snapshot.interventions, const Color(0xFFDB2777)),
      _BarItem('Emails sent', snapshot.sentEmails, const Color(0xFF059669)),
      _BarItem('Marketing assets', snapshot.marketingAssets, const Color(0xFFF59E0B)),
    ];
    final maxValue = items.fold<int>(0, (m, i) => math.max(m, i.value));

    return _ChartCard(
      title: 'Activity breakdown',
      child: Column(
        children: [
          for (final item in items) ...[
            _HorizontalBar(item: item, maxValue: maxValue),
            if (item != items.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _BarItem {
  const _BarItem(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

class _HorizontalBar extends StatelessWidget {
  const _HorizontalBar({required this.item, required this.maxValue});

  final _BarItem item;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final fraction = maxValue == 0 ? 0.0 : item.value / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: ManageScreenStyle.lightPrimaryText,
                ),
              ),
            ),
            Text(
              '${item.value}',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ManageScreenStyle.lightPrimaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction.clamp(0, 1),
            minHeight: 8,
            backgroundColor: const Color(0xFFE2E8F0),
            color: item.color,
          ),
        ),
      ],
    );
  }
}

class _OrdersTrendChart extends StatelessWidget {
  const _OrdersTrendChart({required this.snapshot});

  final ReportsSnapshot snapshot;

  List<int> _dailyCounts() {
    final now = DateTime.now();
    final counts = List<int>.filled(7, 0);
    for (final order in snapshot.filteredOrders) {
      final date = ReportPeriod.parseDate(
        order['order_date'] ?? order['created_at'],
      );
      if (date == null) continue;
      final dayDiff = now.difference(
        DateTime(date.year, date.month, date.day),
      ).inDays;
      if (dayDiff >= 0 && dayDiff < 7) {
        counts[6 - dayDiff]++;
      }
    }
    return counts;
  }

  List<String> _dayLabels() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return names[day.weekday - 1];
    });
  }

  @override
  Widget build(BuildContext context) {
    final counts = _dailyCounts();
    final labels = _dayLabels();
    final maxCount = counts.fold<int>(0, math.max);

    return _ChartCard(
      title: 'Orders · last 7 days',
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < 7; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _TrendBar(
                  label: labels[i],
                  value: counts[i],
                  maxValue: maxCount,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendBar extends StatelessWidget {
  const _TrendBar({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  final String label;
  final int value;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final heightFactor = maxValue == 0 ? 0.08 : (value / maxValue).clamp(0.08, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$value',
          style: GoogleFonts.montserrat(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: ManageScreenStyle.lightSecondaryText,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF7C3AED), Color(0xFFC4B5FD)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10,
            color: ManageScreenStyle.lightSecondaryText,
          ),
        ),
      ],
    );
  }
}
