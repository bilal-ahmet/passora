import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import 'second_paywall_congrats_screen.dart';

class SecondPaywallPaymentScreen extends StatefulWidget {
  final String planName;
  final String price;
  final bool isYearly;

  const SecondPaywallPaymentScreen({
    super.key,
    required this.planName,
    required this.price,
    this.isYearly = true,
  });

  @override
  State<SecondPaywallPaymentScreen> createState() =>
      _SecondPaywallPaymentScreenState();
}

class _SecondPaywallPaymentScreenState
    extends State<SecondPaywallPaymentScreen> {
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  // Color constants
  static const Color _magentaPink = Color(0xFFE91E63);
  static const Color _magentaPinkLight = Color(0xFFF06292);

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      resizeToAvoidBottomInset: true,
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
                    _buildPlanSummaryCard(),
                    const SizedBox(height: 32),
                    _buildCardInfoForm(),
                    const SizedBox(height: 32),
                    _buildPriceSummary(),
                    const SizedBox(height: 32),
                    _buildPayButton(),
                    const SizedBox(height: 24),
                    _buildPaymentLogos(),
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

  // ──── APP BAR ────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: _magentaPink,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'payment_details'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  // ──── PLAN SUMMARY CARD ────
  Widget _buildPlanSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _magentaPink.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _magentaPink.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                // Left: Text info
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'plan_summary'.tr().toUpperCase(),
                        style: const TextStyle(
                          color: _magentaPink,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.planName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (widget.isYearly) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _magentaPink.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'discount_50'.tr(),
                                style: const TextStyle(
                                  color: _magentaPinkLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.isYearly ? '₺239.99' : '₺19.99',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              decoration: widget.isYearly
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor:
                                  Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right: Shield icon
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF2D1B4E),
                          const Color(0xFF1A1547),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _magentaPink.withValues(alpha: 0.4),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.shield_outlined,
                        color: _magentaPink.withValues(alpha: 0.8),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──── CARD INFO FORM ────
  Widget _buildCardInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'card_information'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),

        // Name field
        _buildFieldLabel('card_holder_name'),
        const SizedBox(height: 8),
        _buildInputField(
          controller: _nameController,
          placeholder: 'full_name',
        ),

        const SizedBox(height: 16),

        // Card number field
        _buildFieldLabel('card_number'),
        const SizedBox(height: 8),
        _buildInputField(
          controller: _cardNumberController,
          placeholder: '0000 0000 0000 0000',
          keyboardType: TextInputType.number,
          suffixIcon: const Icon(
            Icons.credit_card,
            color: _magentaPink,
            size: 20,
          ),
        ),

        const SizedBox(height: 16),

        // Expiry + CVV row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Son Kullanma'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _expiryController,
                    placeholder: 'AA / YY',
                    keyboardType: TextInputType.datetime,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('CVV'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _cvvController,
                    placeholder: '***',
                    keyboardType: TextInputType.number,
                    obscure: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label.tr(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _magentaPink.withValues(alpha: 0.4),
          width: 1.5,
        ),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: placeholder.tr(),
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 16,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffixIcon,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 20,
            minHeight: 20,
          ),
        ),
      ),
    );
  }

  // ──── PRICE SUMMARY ────
  Widget _buildPriceSummary() {
    final subtotal = widget.isYearly ? '₺239,99' : '₺19,99';
    final discount = widget.isYearly ? '-₺120,00' : null;
    final total = widget.isYearly ? '₺119,99' : '₺19,99';

    return Column(
      children: [
        // Subtotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'subtotal'.tr(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 15,
              ),
            ),
            Text(
              subtotal,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),

        if (discount != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'discount'.tr(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                ),
              ),
              Text(
                discount,
                style: const TextStyle(
                  color: _magentaPink,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        // Divider
        Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.15),
        ),

        const SizedBox(height: 16),

        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'total'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              total,
              style: const TextStyle(
                color: _magentaPink,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ──── PAY BUTTON ────
  Widget _buildPayButton() {
    return GestureDetector(
      onTap: _onPay,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_magentaPink, Color(0xFFC2185B)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _magentaPink.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'secure_payment'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──── PAYMENT LOGOS ────
  Widget _buildPaymentLogos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'VISA',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 20),
        Text(
          'mastercard',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            Icon(
              Icons.verified_user,
              color: Colors.white.withValues(alpha: 0.3),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'SSL SECURE',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ──── ON PAY ────
  void _onPay() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SecondPaywallCongratsScreen(
          planName: widget.planName,
        ),
      ),
    );
  }
}



