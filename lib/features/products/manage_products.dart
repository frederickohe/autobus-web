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
  List<Map<String, dynamic>> _products = const [];
  List<Map<String, dynamic>> _lowStock = const [];
  int _catalogueDocCount = 0;

  String _shortError(String raw, {int max = 160}) {
    final t = raw.trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max)}…';
  }

  Future<void> _loadOverview() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _loadError = null;
    });

    final api = context.read<ApiService>();
    Object? err;
    List<Map<String, dynamic>> products = const [];
    List<Map<String, dynamic>> lowStock = const [];
    var catalogueDocCount = 0;

    try {
      final results = await Future.wait<dynamic>([
        api.listProducts(skip: 0, limit: 200),
        api.getLowStockInventory(),
        api.listMyStorageFiles(folder: ApiService.productCatalogStorageFolder),
      ]);
      products = results[0] as List<Map<String, dynamic>>;
      lowStock = results[1] as List<Map<String, dynamic>>;
      catalogueDocCount = (results[2] as List).length;
    } catch (e) {
      err = e;
    }

    if (!mounted) return;
    setState(() {
      _products = products;
      _lowStock = lowStock;
      _catalogueDocCount = catalogueDocCount;
      _loadError = err?.toString().replaceFirst('Exception: ', '');
      _loading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadRequested) return;
    _loadRequested = true;
    _loadOverview();
  }

  List<Map<String, dynamic>> get _recentProducts {
    final sorted = List<Map<String, dynamic>>.from(_products);
    sorted.sort((a, b) {
      final da = DateTime.tryParse(
        (a['updated_at'] ?? a['created_at'] ?? '').toString(),
      );
      final db = DateTime.tryParse(
        (b['updated_at'] ?? b['created_at'] ?? '').toString(),
      );
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    return sorted.take(4).toList();
  }

  int get _categoryCount {
    final categories = _products
        .map((p) => (p['category'] ?? '').toString().trim())
        .where((c) => c.isNotEmpty)
        .toSet();
    return categories.length;
  }

  void _openAddProduct() {
    Navigator.push<bool?>(
      context,
      MaterialPageRoute<bool?>(builder: (_) => const AddProductScreen()),
    ).then((created) {
      if (created == true && mounted) _loadOverview();
    });
  }

  void _openViewProducts() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const ViewProductsPage()),
    ).then((_) {
      if (mounted) _loadOverview();
    });
  }

  void _openProduct(Map<String, dynamic> product) {
    final id = (product['product_id'] ?? '').toString().trim();
    if (id.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          productId: id,
          initialName: _productName(product),
        ),
      ),
    ).then((refreshed) {
      if (refreshed == true && mounted) _loadOverview();
    });
  }

  static String _productName(Map<String, dynamic> p) =>
      (p['name'] ?? 'Product').toString();

  static String _productPriceLabel(Map<String, dynamic> p) {
    final raw = p['price'];
    double? v;
    if (raw is num) {
      v = raw.toDouble();
    } else {
      v = double.tryParse(raw?.toString() ?? '');
    }
    if (v == null) return '—';
    return 'GHS ${v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2)}';
  }

  static String? _productPhotoUrl(Map<String, dynamic> p) {
    final photo = p['photo']?.toString().trim();
    if (photo != null && photo.isNotEmpty) return photo;
    final photos = p['photos'];
    if (photos is List && photos.isNotEmpty) {
      return photos.first.toString();
    }
    return null;
  }

  static String? _stockLabel(Map<String, dynamic> p) {
    final n = p['number_in_stock'];
    if (n == null) return null;
    if (n is int) return '$n in stock';
    if (n is num) return '${n.toInt()} in stock';
    return '$n in stock';
  }

  @override
  Widget build(BuildContext context) {
    final light = ManageScreenStyle.useLightTheme;

    return Scaffold(
      backgroundColor: ManageScreenStyle.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(decoration: ManageScreenStyle.bodyDecoration()),
          SafeArea(
            child: Column(
              children: [
                ManageScreenHeader(
                  title: 'Manage Products',
                  onDarkBackground: !light,
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: CustColors.mainCol,
                    onRefresh: _loadOverview,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 24),
                            Text(
                              'Products',
                              textAlign: TextAlign.center,
                              style: ManageScreenStyle.hubWelcomeTitleStyle(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage inventory, upload catalogues, and keep listings up to date.',
                              textAlign: TextAlign.center,
                              style: ManageScreenStyle.hubWelcomeSubtitleStyle(),
                            ),
                            const SizedBox(height: 24),
                            if (_loading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Center(
                                  child: AutobusLoadingIndicator(size: 28),
                                ),
                              )
                            else ...[
                              if (_loadError != null)
                                _ProductNoticePanel(
                                  backgroundColor: Colors.amber.withValues(
                                    alpha: light ? 0.12 : 0.12,
                                  ),
                                  borderColor: Colors.amber.withValues(
                                    alpha: 0.45,
                                  ),
                                  icon: Icons.cloud_off_outlined,
                                  iconColor: Colors.amber.shade700,
                                  trailing: IconButton(
                                    onPressed: _loadOverview,
                                    icon: Icon(
                                      Icons.refresh,
                                      color: light
                                          ? ManageScreenStyle.lightSecondaryText
                                          : Colors.white70,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  ),
                                  child: Text(
                                    'Could not refresh overview.\n${_shortError(_loadError!)}',
                                    style: GoogleFonts.montserrat(
                                      color: light
                                          ? ManageScreenStyle.lightPrimaryText
                                          : Colors.white.withValues(alpha: 0.88),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              if (_loadError == null) ...[
                                _ProductsOverviewPanel(
                                  totalProducts: _products.length,
                                  lowStockCount: _lowStock.length,
                                  categoryCount: _categoryCount,
                                  catalogueDocCount: _catalogueDocCount,
                                  recentProducts: _recentProducts,
                                  onProductTap: _openProduct,
                                  onViewAll: _openViewProducts,
                                ),
                                const SizedBox(height: 24),
                              ],
                            ],
                            ManageHubGrid(
                              children: [
                                ManageHubActionCard(
                                  icon: Icons.add_box_outlined,
                                  label: 'Add Product',
                                  onTap: _openAddProduct,
                                ),
                                ManageHubActionCard(
                                  icon: Icons.inventory_2_outlined,
                                  label: 'View Products',
                                  onTap: _openViewProducts,
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
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

class _ProductsOverviewPanel extends StatelessWidget {
  const _ProductsOverviewPanel({
    required this.totalProducts,
    required this.lowStockCount,
    required this.categoryCount,
    required this.catalogueDocCount,
    required this.recentProducts,
    required this.onProductTap,
    required this.onViewAll,
  });

  final int totalProducts;
  final int lowStockCount;
  final int categoryCount;
  final int catalogueDocCount;
  final List<Map<String, dynamic>> recentProducts;
  final ValueChanged<Map<String, dynamic>> onProductTap;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final light = ManageScreenStyle.useLightTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: light ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: light ? ManageScreenStyle.lightBorder : const Color(0xFF3F1163),
        ),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Overview',
                  style: ManageScreenStyle.hubSectionTitleStyle(),
                ),
              ),
              if (totalProducts > 0)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    foregroundColor: CustColors.mainCol,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View all',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _OverviewStatChip(
                label: 'Products',
                value: '$totalProducts',
                icon: Icons.inventory_2_outlined,
              ),
              _OverviewStatChip(
                label: 'Low stock',
                value: '$lowStockCount',
                icon: Icons.warning_amber_outlined,
                highlight: lowStockCount > 0,
              ),
              if (categoryCount > 0)
                _OverviewStatChip(
                  label: 'Categories',
                  value: '$categoryCount',
                  icon: Icons.category_outlined,
                ),
              if (catalogueDocCount > 0)
                _OverviewStatChip(
                  label: 'Catalogue files',
                  value: '$catalogueDocCount',
                  icon: Icons.folder_outlined,
                ),
            ],
          ),
          if (recentProducts.isEmpty) ...[
            const SizedBox(height: 16),
            Text(
              totalProducts == 0
                  ? 'No products yet. Add your first product to get started.'
                  : 'No recent products to show.',
              style: GoogleFonts.montserrat(
                color: light
                    ? ManageScreenStyle.lightSecondaryText
                    : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            for (var i = 0; i < recentProducts.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  color: light
                      ? ManageScreenStyle.lightBorder
                      : const Color(0xFF3F1163),
                ),
              _RecentProductRow(
                product: recentProducts[i],
                onTap: () => onProductTap(recentProducts[i]),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _OverviewStatChip extends StatelessWidget {
  const _OverviewStatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final light = ManageScreenStyle.useLightTheme;
    final accent = highlight ? const Color(0xFFEF4444) : CustColors.mainCol;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: light
            ? accent.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: light
              ? accent.withValues(alpha: 0.2)
              : const Color(0xFF3F1163),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.montserrat(
              color: light
                  ? ManageScreenStyle.lightPrimaryText
                  : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.montserrat(
              color: light
                  ? ManageScreenStyle.lightSecondaryText
                  : Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentProductRow extends StatelessWidget {
  const _RecentProductRow({required this.product, required this.onTap});

  final Map<String, dynamic> product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final light = ManageScreenStyle.useLightTheme;
    final photoUrl = _ManageProductsState._productPhotoUrl(product);
    final stock = _ManageProductsState._stockLabel(product);
    final category = (product['category'] ?? '').toString().trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  color: light
                      ? ManageScreenStyle.lightBorder
                      : const Color(0xFF3F1163),
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_not_supported_outlined,
                            size: 18,
                            color: light
                                ? ManageScreenStyle.lightSecondaryText
                                : Colors.white54,
                          ),
                        )
                      : Icon(
                          Icons.inventory_2_outlined,
                          size: 18,
                          color: light
                              ? ManageScreenStyle.lightSecondaryText
                              : Colors.white54,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ManageProductsState._productName(product),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        color: light
                            ? ManageScreenStyle.lightPrimaryText
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        _ManageProductsState._productPriceLabel(product),
                        if (stock != null) stock,
                        if (category.isNotEmpty) category,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        color: light
                            ? ManageScreenStyle.lightSecondaryText
                            : Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: light
                    ? ManageScreenStyle.lightSecondaryText
                    : Colors.white54,
              ),
            ],
          ),
        ),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(child: child),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
