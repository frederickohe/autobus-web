import 'package:autobus/barrel.dart';

/// Local subscription catalog.
/// embedded JSON
class SubscriptionCatalog {
  static const String _catalogJson = r'''
  {
    "plans": [
      {
        "id": "free",
        "name": "Free Trial",
        "priceText": "$0/mo",
        "features": [
          "Order Management",
          "Emailing",
          "Customer Service"
        ],
        "billing": [
          {"id": "trial", "label": "14", "subtitle": "Days", "price": 0}
        ]
      },
      {
        "id": "basic",
        "name": "Basic",
        "priceText": "$3/mo",
        "features": [
          "Order Management",
          "Emailing",
          "Customer Service"
        ],
        "billing": [
          {"id": "m1", "label": "1", "subtitle": "Month", "price": 15},
          {"id": "y1", "label": "1", "subtitle": "Year", "price": 120},
          {"id": "y3", "label": "3", "subtitle": "Years Combo", "price": 450}
        ]
      },
      {
        "id": "standard",
        "name": "Standard",
        "priceText": "$6/mo",
        "features": [
          "Order Management",
          "Emailing",
          "Customer Service"
        ],
        "billing": [
          {"id": "m1", "label": "1", "subtitle": "Month", "price": 25},
          {"id": "y1", "label": "1", "subtitle": "Year", "price": 200},
          {"id": "y3", "label": "3", "subtitle": "Years Combo", "price": 750}
        ]
      },
      {
        "id": "enterprise",
        "name": "Enterprise",
        "priceText": "$15/mo",
        "features": [
          "Order Management",
          "Emailing",
          "Customer Service"
        ],
        "billing": [
          {"id": "m1", "label": "1", "subtitle": "Month", "price": 60},
          {"id": "y1", "label": "1", "subtitle": "Year", "price": 600},
          {"id": "y3", "label": "3", "subtitle": "Years Combo", "price": 2000}
        ]
      }
    ]
  }
  ''';

  static List<SubscriptionPlan> loadPlans() {
    final decoded = jsonDecode(_catalogJson) as Map<String, dynamic>;
    final plans = (decoded['plans'] as List).cast<dynamic>();
    return plans
        .map(
          (p) => SubscriptionPlan.fromJson((p as Map).cast<String, dynamic>()),
        )
        .toList();
  }
}
