import 'package:autobus/barrel.dart';

class SubscriptionStorage {
  static const _kPlanId = 'subscription.planId';
  static const _kBillingId = 'subscription.billingId';

  Future<void> saveSelection({
    required String planId,
    required String billingId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPlanId, planId);
    await prefs.setString(_kBillingId, billingId);
  }

  Future<(String? planId, String? billingId)> loadSelection() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_kPlanId), prefs.getString(_kBillingId));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPlanId);
    await prefs.remove(_kBillingId);
  }

  Future<void> savePlanSnapshot(
    SubscriptionPlan plan,
    BillingOption billing,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'subscription.snapshot',
      jsonEncode({'plan': plan.toJson(), 'billing': billing.toJson()}),
    );
  }
}
