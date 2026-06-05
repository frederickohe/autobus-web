import 'package:autobus/barrel.dart';

class BillingOption extends Equatable {
  final String id;
  final String label;
  final String subtitle;
  final double price;

  const BillingOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'subtitle': subtitle,
    'price': price,
  };

  @override
  List<Object?> get props => [id, label, subtitle, price];
}

class SubscriptionPlan extends Equatable {
  final int id;
  final String name;
  final double price;
  final List<String> features;
  final List<String> agents;
  final String description;
  final bool isActive;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
    this.agents = const [],
    required this.description,
    required this.isActive,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse((json['id'] ?? '0').toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse((json['price'] ?? '0').toString()) ?? 0,
      features: ((json['features'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      agents: ((json['agents'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      description: (json['description'] ?? '').toString(),
      isActive: json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'features': features,
      'agents': agents,
      'description': description,
      'is_active': isActive,
    };
  }

  List<BillingOption> get billing => [
    BillingOption(
      id: 'monthly',
      label: 'Monthly',
      subtitle: 'per month',
      price: price,
    ),
    BillingOption(
      id: 'annual',
      label: 'Annual',
      subtitle: 'per year',
      price: _annualPrice,
    ),
  ];

  /// Full year total: 12 × monthly plan price (no bundled discount factor).
  double get _annualPrice =>
      double.parse((price * 12).toStringAsFixed(2));

  String get priceText => price == 0 ? 'Free' : 'from GHS $price/mo';

  /// API agent ids are often snake_case (e.g. `email_agent`); show as title text.
  static String formatAgentLabel(String raw) {
    final normalized = raw.trim().replaceAll('_', ' ');
    if (normalized.isEmpty) return raw;
    return normalized
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map(
          (w) =>
              '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1).toLowerCase() : ''}',
        )
        .join(' ');
  }

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    features,
    agents,
    description,
    isActive,
  ];
}
