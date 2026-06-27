import 'package:autobus/barrel.dart';

/// Lists archived digital marketing payloads from
/// `GET /api/v1/social/digital-marketing/assets`.
class RecentCampaignsPage extends StatefulWidget {
  const RecentCampaignsPage({super.key});

  @override
  State<RecentCampaignsPage> createState() => _RecentCampaignsPageState();
}

class _RecentCampaignsPageState extends State<RecentCampaignsPage> {
  List<Map<String, dynamic>> _items = const [];
  int _total = 0;
  bool _loading = true;
  String? _loadError;

  String _previewText(Map<String, dynamic> m) {
    final t = (m['marketing_text'] ?? '').toString().trim();
    if (t.isEmpty) return 'Campaign';
    if (t.length <= 120) return t;
    return '${t.substring(0, 117)}…';
  }

  String _createdLabel(Map<String, dynamic> m) {
    final raw = (m['created_at'] ?? '').toString();
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw.isEmpty ? '—' : raw;
    final d = dt.toLocal();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$dd / $mm / ${d.year}';
  }

  int _linkCount(Map<String, dynamic> m) {
    final links = m['content_links'];
    if (links is List) return links.length;
    return 0;
  }

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
      final api = context.read<ApiService>();
      final body = await api.listDigitalMarketingAssets(limit: 50, offset: 0);
      if (!mounted) return;
      final raw = body['items'];
      final list = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map<String, dynamic>) {
            list.add(e);
          } else if (e is Map) {
            list.add(Map<String, dynamic>.from(e));
          }
        }
      }
      final tot = body['total'];
      setState(() {
        _items = list;
        _total = tot is int ? tot : (tot is num ? tot.toInt() : list.length);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
        _items = const [];
        _total = 0;
      });
    }
  }

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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ManageScreenBackButton(),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          'Recent campaigns',
                          style: ManageScreenStyle.headerTitleStyle(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _loading ? ' ' : '$_total saved',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child:                             const AutobusLoadingIndicator(size: 32),
                          )
                        : _loadError != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    _loadError!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: _load,
                                  child: Text(
                                    'Retry',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFA855F7),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: const Color(0xFFA855F7),
                            onRefresh: _load,
                            child: _items.isEmpty
                                ? ListView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                            0.22,
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: Text(
                                            'No campaigns yet. Publish from Digital Marketing with Postiz to see them here.',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.outfit(
                                              color: Colors.white.withValues(
                                                alpha: 0.6,
                                              ),
                                              fontSize: 15,
                                              height: 1.45,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: _items.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final m = _items[index];
                                      final links = _linkCount(m);
                                      return Container(
                                        padding: const EdgeInsets.all(22),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFF3F1163),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _previewText(m),
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                height: 1.35,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    (m['agent_name'] ?? '')
                                                        .toString(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.45,
                                                          ),
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  _createdLabel(m),
                                                  style: GoogleFonts.outfit(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.45,
                                                        ),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (links > 0) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                '$links attachment${links == 1 ? '' : 's'}',
                                                style: GoogleFonts.outfit(
                                                  color: const Color(
                                                    0xFFA855F7,
                                                  ),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
