import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Local A/B test service for paywall group assignment.
/// Assigns user to group 0 or 1 on first launch, persists the choice.
class ABTestService {
  static const String _groupKey = 'ab_test_paywall_group';
  static const String _overrideKey = 'ab_test_paywall_override';

  static ABTestService? _instance;
  static ABTestService get instance => _instance ??= ABTestService._();
  ABTestService._();

  int? _cachedGroup;

  /// Get the user's paywall group (0 or 1).
  /// Assigns randomly on first call; persists forever after.
  Future<int> getPaywallGroup() async {
    if (_cachedGroup != null) return _cachedGroup!;

    final prefs = await SharedPreferences.getInstance();

    // Check for manual override first
    final override = prefs.getInt(_overrideKey);
    if (override != null) {
      _cachedGroup = override;
      return override;
    }

    // Check if already assigned
    final existing = prefs.getInt(_groupKey);
    if (existing != null) {
      _cachedGroup = existing;
      return existing;
    }

    // First launch: assign randomly
    final group = Random().nextInt(2); // 0 or 1
    await prefs.setInt(_groupKey, group);
    _cachedGroup = group;
    return group;
  }

  /// Override the paywall group manually (from Settings).
  /// Pass null to clear override and revert to original assignment.
  Future<void> setPaywallOverride(int? group) async {
    final prefs = await SharedPreferences.getInstance();
    if (group == null) {
      await prefs.remove(_overrideKey);
    } else {
      await prefs.setInt(_overrideKey, group);
    }
    _cachedGroup = null; // Clear cache so next read picks up override
  }

  /// Get the original (non-overridden) group assignment.
  Future<int> getOriginalGroup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_groupKey) ?? 0;
  }

  /// Clear cache (useful for testing).
  void clearCache() {
    _cachedGroup = null;
  }
}
