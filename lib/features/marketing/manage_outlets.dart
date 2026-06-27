import 'package:autobus/barrel.dart';
import 'package:autobus/features/marketing/outlet_catalog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ManageOutlets extends StatefulWidget {
  const ManageOutlets({super.key});

  @override
  State<ManageOutlets> createState() => _ManageOutletsState();
}

class _ManageOutletsState extends State<ManageOutlets> {
  var _loading = true;
  String? _loadError;
  List<LinkedOutlet> _linked = [];
  List<OutletOption> _unlinked = OutletCatalog.all;

  @override
  void initState() {
    super.initState();
    _refreshIntegrations();
  }

  Future<void> _refreshIntegrations() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final api = context.read<ApiService>();
      final integrations = await api.listPostizIntegrations();
      if (!mounted) return;
      final split = OutletCatalog.partition(integrations);
      setState(() {
        _linked = split.linked;
        _unlinked = split.unlinked;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
        _linked = [];
        _unlinked = OutletCatalog.all;
        _loading = false;
      });
    }
  }

  Future<void> _linkOutlet(OutletOption outlet) async {
    final api = context.read<ApiService>();
    await openEmbeddedPlatformSession(
      context,
      title: 'Link ${outlet.label}',
      fetchSession: () => api.postizAutoLogin(),
    );

    if (mounted) {
      await _refreshIntegrations();
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const ManageScreenBackButton(),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          'Link Social Media',
                          style: ManageScreenStyle.headerTitleStyle(context),
                        ),
                      ),
                      if (!_loading)
                        IconButton(
                          onPressed: _refreshIntegrations,
                          icon: const Icon(Icons.refresh, color: Colors.white70),
                          tooltip: 'Refresh',
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _loading
                        ? const Center(child: AutobusLoadingIndicator(size: 32))
                        : RefreshIndicator(
                            onRefresh: _refreshIntegrations,
                            color: Colors.white,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_loadError != null) ...[
                                    Text(
                                      _loadError!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.amber.shade200,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  Text(
                                    'Linked Outlets',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (_linked.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        'No outlets linked yet. Connect a channel below.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white.withValues(
                                            alpha: 0.55,
                                          ),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          height: 1.45,
                                        ),
                                      ),
                                    )
                                  else
                                    _OutletGrid(
                                      children: [
                                        for (final item in _linked)
                                          _OutletCard(
                                            label: item.outlet.label,
                                            subtitle: item.subtitle,
                                            icon: FaIcon(item.outlet.icon),
                                            iconColor: item.outlet.iconColor,
                                            isLinked: true,
                                            onTap: () => _linkOutlet(item.outlet),
                                          ),
                                      ],
                                    ),
                                  const SizedBox(height: 28),
                                  Text(
                                    'Select to Link Social Media',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Postiz opens in-app: sign in with your Postiz account, then tap Continue to connect your social channel on the integrations page.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white.withValues(alpha: 0.65),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (_unlinked.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        'All available outlets are linked.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white.withValues(
                                            alpha: 0.55,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),
                                    )
                                  else
                                    _OutletGrid(
                                      children: [
                                        for (final outlet in _unlinked)
                                          _OutletCard(
                                            label: outlet.label,
                                            icon: FaIcon(outlet.icon),
                                            iconColor: outlet.iconColor,
                                            onTap: () => _linkOutlet(outlet),
                                          ),
                                      ],
                                    ),
                                  const SizedBox(height: 24),
                                ],
                              ),
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

class _OutletGrid extends StatelessWidget {
  final List<Widget> children;

  const _OutletGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 133 / 89,
      children: children,
    );
  }
}

class _OutletCard extends StatelessWidget {
  final String label;
  final String? subtitle;
  final Widget icon;
  final Color iconColor;
  final bool isLinked;
  final VoidCallback onTap;

  const _OutletCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.subtitle,
    this.isLinked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1333).withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLinked ? const Color(0xFF22C55E) : const Color(0xFF3F1163),
            width: isLinked ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: IconTheme(
                data: IconThemeData(color: iconColor, size: 40),
                child: icon,
              ),
            ),
            if (isLinked)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF22C55E),
                  size: 18,
                ),
              ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
