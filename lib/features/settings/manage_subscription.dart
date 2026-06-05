import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:autobus/common_design/colors.dart';
import 'package:autobus/common_design/widgets/autobus_loading_indicator.dart';
import 'package:autobus/features/home/services/api_service.dart';
import 'package:autobus/features/subscription/userplan.dart';

/// [RouteSettings.name] for [Navigator.popUntil] after plan purchase from this flow.
const String kManageSubscriptionRouteName = 'ManageSubscription';

class ManageSubscriptionPage extends StatefulWidget {
  const ManageSubscriptionPage({super.key});

  @override
  State<ManageSubscriptionPage> createState() => _ManageSubscriptionPageState();
}

class _ManageSubscriptionPageState extends State<ManageSubscriptionPage> {
  Map<String, dynamic>? _status;
  bool _loading = true;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([_loadEmail(), _loadStatus()]);
  }

  Future<void> _loadEmail() async {
    try {
      final user = await context.read<ApiService>().getUserProfile();
      if (!mounted) return;
      setState(() {
        _userEmail = (user['email'] ?? user['user_email'] ?? '').toString();
      });
    } catch (_) {}
  }

  Future<void> _loadStatus() async {
    setState(() {
      _loading = true;
    });
    try {
      final api = context.read<ApiService>();
      final s = await api.getMySubscriptionStatus();
      if (!mounted) return;
      setState(() {
        _status = s;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = null;
        _loading = false;
      });
    }
  }

  bool get _hasActive {
    final s = _status;
    if (s == null) return false;
    return s['has_active_subscription'] == true;
  }

  String get _planName =>
      (_status?['plan_name'] ?? '').toString().trim().isEmpty
      ? '—'
      : (_status!['plan_name']).toString();

  int get _daysRemaining {
    final v = _status?['days_remaining'];
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }

  double? get _planPrice {
    final v = _status?['plan_price'];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }

  String _renewalLine() {
    if (!_hasActive) return 'Choose a plan to unlock premium features.';
    final d = _daysRemaining;
    if (d > 1) return '$d days until renewal';
    if (d == 1) return '1 day until renewal';
    return 'Renews today';
  }

  String? _expiresLine() {
    final raw = _status?['expires_at']?.toString();
    if (raw == null || raw.isEmpty) return null;
    try {
      final dt = DateTime.tryParse(raw);
      if (dt == null) return 'Renews on $raw';
      final local = dt.toLocal();
      final mm = local.month.toString().padLeft(2, '0');
      final dd = local.day.toString().padLeft(2, '0');
      return 'Renewal date: ${local.year}-$mm-$dd';
    } catch (_) {
      return null;
    }
  }

  Future<void> _openPlanPicker({required bool upgrade}) async {
    var email = _userEmail.trim();
    if (email.isEmpty) {
      try {
        final user = await context.read<ApiService>().getUserProfile();
        email = (user['email'] ?? user['user_email'] ?? '').toString().trim();
        if (mounted) setState(() => _userEmail = email);
      } catch (_) {}
    }
    if (!mounted) return;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add an email on your profile before changing plans.'),
        ),
      );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'ManageSubscriptionSelectPlan'),
        builder: (_) => SelectPlan(
          userEmail: email,
          upgradeFromActivePlan: upgrade,
          minExclusivePlanPrice: upgrade ? _planPrice : null,
          successPopUntilRouteName: kManageSubscriptionRouteName,
        ),
      ),
    );
    if (mounted) await _loadStatus();
  }

  Future<void> _confirmCancel() async {
    final reasonCtrl = TextEditingController();
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Cancel subscription?', style: GoogleFonts.montserrat()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You will lose access to subscription features when the current period ends, depending on server policy.',
                style: GoogleFonts.montserrat(fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                maxLength: 500,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep subscription'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Cancel plan',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        );
      },
    );
    final reasonText = reasonCtrl.text.trim();
    reasonCtrl.dispose();
    if (go != true || !mounted) return;

    try {
      await context.read<ApiService>().cancelMySubscription(
        reason: reasonText.isEmpty ? null : reasonText,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Subscription cancelled.')));
      await _loadStatus();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not cancel: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 244, 244, 244),
              Color.fromARGB(255, 236, 236, 236),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadStatus,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CustColors.mainCol,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Subscription',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(
                            child: AutobusLoadingIndicator(size: 36),
                          ),
                        )
                      else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hasActive ? _planName : 'No active plan',
                                style: GoogleFonts.montserrat(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _renewalLine(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              if (_expiresLine() != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _expiresLine()!,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _hasActive
                                ? () => _openPlanPicker(upgrade: true)
                                : () => _openPlanPicker(upgrade: false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustColors.mainCol,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _hasActive
                                  ? 'Upgrade or change plan'
                                  : 'Choose a plan',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (_hasActive) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _confirmCancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade800,
                                side: BorderSide(color: Colors.red.shade200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel subscription',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
