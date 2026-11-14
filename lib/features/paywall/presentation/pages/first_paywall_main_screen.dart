import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import 'first_paywall_payment_screen.dart';

/// Selected plan type for the paywall.
enum PaywallPlan { free, monthly, yearly }

class FirstPaywallMainScreen extends StatefulWidget {
  const FirstPaywallMainScreen({super.key});

  @override
  State<FirstPaywallMainScreen> createState() => _FirstPaywallMainScreenState();
}

class _FirstPaywallMainScreenState extends State<FirstPaywallMainScreen> {
  PaywallPlan _selectedPlan = PaywallPlan.yearly;

  // Paywall color constants
  static const Color _hotPink = Color(0xFFE91E63);
  static const Color _hotPinkLight = Color(0xFFFF4F8E);
  static const Color _darkPurple = Color(0xFF9C27B0);

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildFreePlanCard(),
                    const SizedBox(height: 16),
                    _buildMonthlyPlanCard(),
                    const SizedBox(height: 16),
                    _buildYearlyPlanCard(),
                    const SizedBox(height: 24),
                    _buildMainCTAButton(),
                    const SizedBox(height: 16),
                    _buildDisclaimer(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const Expanded(
            child: Text(
              'Passora',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 24), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'choose_your_plan'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'remove_all_limitations'.tr(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────── FREE PLAN ────────────────────────────

  Widget _buildFreePlanCard() {
    return _buildGlassCard(
      borderColor: Colors.white.withValues(alpha: 0.2),
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PASSORA BASIC',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Image.asset(
                  'assets/elements/first_paywall_lock.png',
                  width: 24,
                  height: 24,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'free_forever'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '/forever',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Password storage section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'password_storage'.tr(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '35/35 ${'used'.tr()}',
                  style: const TextStyle(
                    color: _hotPinkLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_hotPinkLight, _hotPink],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'limit_reached'.tr(),
                style: const TextStyle(
                  color: _hotPinkLight,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Features list
            _buildFeatureRow(
              icon: 'assets/elements/first_paywall_okey.png',
              text: 'password_limit',
              enabled: true,
              iconColor: const Color(0xFF9E9E9E),
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              icon: 'assets/elements/first_paywall_okey.png',
              text: 'basic_encryption',
              enabled: true,
              iconColor: const Color(0xFF9E9E9E),
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              icon: 'assets/elements/first_paywall_not_okey.png',
              text: 'cloud_sync',
              enabled: false,
            ),

            const SizedBox(height: 24),

            // Current Plan button
            _buildOutlineButton(
              text: 'current_plan',
              textColor: Colors.white.withValues(alpha: 0.7),
              borderColor: Colors.white.withValues(alpha: 0.3),
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────── MONTHLY PLAN ────────────────────────────

  Widget _buildMonthlyPlanCard() {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPlan = PaywallPlan.monthly);
      },
      child: _buildGlassCard(
        borderColor: _selectedPlan == PaywallPlan.monthly
            ? _hotPink.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.2),
        borderWidth: _selectedPlan == PaywallPlan.monthly ? 1.5 : 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'monthly_starter'.tr().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Icon(
                    Icons.diamond_outlined,
                    color: _hotPink,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '24.99 ₺',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'month'.tr(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Features
              _buildFeatureRow(
                icon: 'assets/elements/first_paywall_color_okey.png',
                text: 'unlimited_passwords',
                enabled: true,
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(
                icon: 'assets/elements/first_paywall_color_okey.png',
                text: 'sync_2_devices',
                enabled: true,
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(
                icon: 'assets/elements/first_paywall_color_okey.png',
                text: 'priority_support',
                enabled: true,
              ),

              const SizedBox(height: 24),

              // Select Monthly button
              _buildOutlineButton(
                text: 'select_monthly',
                textColor: Colors.white.withValues(alpha: 0.9),
                borderColor: Colors.white.withValues(alpha: 0.3),
                onTap: () {
                  setState(() => _selectedPlan = PaywallPlan.monthly);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────── YEARLY PLAN ────────────────────────────

  Widget _buildYearlyPlanCard() {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPlan = PaywallPlan.yearly);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _hotPink, width: 2),
          boxShadow: [
            BoxShadow(
              color: _hotPink.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'yearly_full_protection'.tr().toUpperCase(),
                          style: TextStyle(
                            color: _hotPinkLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: _hotPink.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '149.99 ₺',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'year'.tr(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Features with colored icons
                        _buildYearlyFeatureRow(
                          assetPath: 'assets/elements/first_paywall_unlimited_password.png',
                          text: 'unlimited_passwords',
                        ),
                        const SizedBox(height: 14),
                        _buildYearlyFeatureRow(
                          assetPath: 'assets/elements/first_paywall_sync_all_devices.png',
                          text: 'sync_all_devices',
                        ),
                        const SizedBox(height: 14),
                        _buildYearlyFeatureRow(
                          assetPath: 'assets/elements/first_paywall_advanced_security.png',
                          text: 'advanced_security',
                        ),
                        const SizedBox(height: 14),
                        _buildYearlyFeatureRow(
                          assetPath: 'assets/elements/first_paywall_best_value_price.png',
                          text: 'best_value_price',
                        ),

                        const SizedBox(height: 24),

                        // Select Best Value button
                        _buildGradientButton(
                          text: 'select_best_value',
                          gradient: const LinearGradient(
                            colors: [_hotPink, Color(0xFFC2185B)],
                          ),
                          onTap: () {
                            setState(() => _selectedPlan = PaywallPlan.yearly);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Discount badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Transform.rotate(
                      angle: 0.05,
                      child: Image.asset(
                        'assets/elements/first_paywall_%50indirim.png',
                        width: 100,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────── BOTTOM CTA ────────────────────────────

  Widget _buildMainCTAButton() {
    return GestureDetector(
      onTap: _onContinue,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_hotPink, _darkPurple],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _hotPink.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'unlock_all_features_now'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Center(
      child: Text(
        'free_usage_available'.tr(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // ──────────────────────────── SHARED WIDGETS ────────────────────────────

  Widget _buildGlassCard({
    required Widget child,
    required Color borderColor,
    double borderWidth = 1,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required String icon,
    required String text,
    required bool enabled,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Image.asset(
          icon,
          width: 22,
          height: 22,
        ),
        const SizedBox(width: 12),
        Text(
          text.tr(),
          style: TextStyle(
            color: enabled
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.4),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            decoration: enabled ? null : TextDecoration.lineThrough,
            decorationColor: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildYearlyFeatureRow({
    required String assetPath,
    required String text,
  }) {
    return Row(
      children: [
        Image.asset(
          assetPath,
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 12),
        Text(
          text.tr(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOutlineButton({
    required String text,
    required Color textColor,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Center(
          child: Text(
            text.tr(),
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _hotPink.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────── NAVIGATION ────────────────────────────

  void _onContinue() {
    if (_selectedPlan == PaywallPlan.free) return;

    final planName = _selectedPlan == PaywallPlan.yearly
        ? 'Yearly Full Protection'
        : 'Monthly Starter';
    final price = _selectedPlan == PaywallPlan.yearly ? '299,99 ₺' : '99,00 ₺';
    final hasDiscount = _selectedPlan == PaywallPlan.yearly;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FirstPaywallPaymentScreen(
          planName: planName,
          originalPrice: price,
          hasDiscount: hasDiscount,
        ),
      ),
    );
  }
}
