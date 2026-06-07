import 'package:autobus/barrel.dart';

class ManageProducts extends StatefulWidget {
  const ManageProducts({super.key});

  @override
  State<ManageProducts> createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  bool _loadRequested = false;
  bool _loading = true;
  String? _loadError;
  bool _hasCatalogueFiles = false;

  String _shortError(String raw, {int max = 160}) {
    final t = raw.trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max)}…';
  }

  Future<void> _loadCataloguePresence() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final api = context.read<ApiService>();
      final files = await api.listMyStorageFiles(
        folder: ApiService.productCatalogStorageFolder,
      );
      if (!mounted) return;
      setState(() {
        _hasCatalogueFiles = files.isNotEmpty;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
        _hasCatalogueFiles = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadRequested) return;
    _loadRequested = true;
    _loadCataloguePresence();
  }

  @override
  Widget build(BuildContext context) {
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
                const ManageScreenHeader(title: 'Manage Products'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            'Welcome to Products',
                            textAlign: TextAlign.center,
                            style: ManageScreenStyle.hubWelcomeTitleStyle(),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Manage and organize product documents with automated recommendations, updates, and insights from your AI assistant.',
                            textAlign: TextAlign.center,
                            style: ManageScreenStyle.hubWelcomeSubtitleStyle(),
                          ),
                          const SizedBox(height: 32),
                          if (_loading) ...[
                            const SizedBox(height: 8),
                            const Center(
                              child:                               const AutobusLoadingIndicator(size: 28),
                            ),
                            const SizedBox(height: 24),
                          ] else if (_loadError != null) ...[
                            _ProductNoticePanel(
                              backgroundColor: Colors.amber.withValues(
                                alpha: 0.12,
                              ),
                              borderColor: Colors.amber.withValues(alpha: 0.45),
                              icon: Icons.cloud_off_outlined,
                              iconColor: Colors.amber.shade300,
                              trailing: IconButton(
                                onPressed: _loadCataloguePresence,
                                icon: Icon(
                                  Icons.refresh,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  size: 22,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                              child: Text(
                                'Could not verify your product catalogue.\n${_shortError(_loadError!)}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ] else if (!_hasCatalogueFiles) ...[
                            _ProductNoticePanel(
                              backgroundColor: const Color(
                                0xFF581C87,
                              ).withValues(alpha: 0.1),
                              borderColor: const Color(
                                0xFF9333EA,
                              ).withValues(alpha: 0.5),
                              icon: Icons.warning_rounded,
                              iconColor: Colors.red.shade400,
                              child: Text(
                                'You have no products in your catalogue.',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ] else
                            const SizedBox(height: 8),
                          const SizedBox(height: 40),
                          ManageHubGrid(
                            children: [
                              ManageHubActionCard(
                                icon: Icons.add_box_outlined,
                                label: 'Add Product',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) => const AutoBus(
                                        title: 'Products',
                                        webhookContext: 'products_agent',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ManageHubActionCard(
                                icon: Icons.inventory_2_outlined,
                                label: 'View Products',
                                onTap: () {
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const ViewProductsPage(),
                                    ),
                                  ).then((_) {
                                    if (mounted) _loadCataloguePresence();
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
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

class _ProductNoticePanel extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  final Widget child;

  const _ProductNoticePanel({
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(child: child),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
