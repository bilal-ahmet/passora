import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';
import 'second_paywall_payment_screen.dart';

/// Selected plan type for second paywall design.
enum SecondPaywallPlan { monthly, yearly }

class SecondPaywallMainScreen extends StatefulWidget {
  const SecondPaywallMainScreen({super.key});

  @override
  State<SecondPaywallMainScreen> createState() =>
      _SecondPaywallMainScreenState();
}

class _SecondPaywallMainScreenState extends State<SecondPaywallMainScreen> {
  SecondPaywallPlan _selectedPlan = SecondPaywallPlan.yearly;

  // Color constants
  static const Color _magentaPink = Color(0xFFE91E63);
  static const Color _magentaPinkLight = Color(0xFFF06292);

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
                    const SizedBox(height: 20),
                    _buildBasicLimitCard(),
                    const SizedBox(height: 28),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildPlanCards(),
                    const SizedBox(height: 24),
                    _buildFeatureHighlights(),
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

  // ──── APP BAR ────
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
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  // ──── BASIC LIMIT CARD ────
  Widget _buildBasicLimitCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              // Lock icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _magentaPink.withValues(alpha: 0.3),
                      _magentaPink.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.lock,
                  color: _magentaPink,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'basic_limit'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'standard_plan'.tr(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'password_limit_reached'.tr(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Text(
                          '35/35',
                          style: TextStyle(
                            color: _magentaPink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 1.0,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor:
                            const AlwaysStoppedAnimation(_magentaPink),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──── HEADER ────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'choose_your_plan'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'remove_all_limitations'.tr(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ──── PLAN CARDS ────
  Widget _buildPlanCards() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildMonthlyCard()),
        const SizedBox(width: 12),
        Expanded(child: _buildYearlyCard()),
      ],
    );
  }

  // ──── MONTHLY PLAN CARD ────
  Widget _buildMonthlyCard() {
    final isSelected = _selectedPlan == SecondPaywallPlan.monthly;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = SecondPaywallPlan.monthly),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? _magentaPink.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2A1B3D).withValues(alpha: 0.6),
              const Color(0xFF2A1B3D).withValues(alpha: 0.3),
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'monthly'.tr().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'starter'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Icons - 2+1 grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIconCircle(
                        assetPath:
                            'assets/elements/second_paywall_mounth_key.png',
                        isYearly: false,
                        onTap: () => _showFeaturePopup(
                          title: 'Temel Şifre Yönetimi',
                          description:
                              'Tüm şifrelerinizi tek bir güvenli yerde saklayın. Güçlü şifre oluşturucu ile karmaşık şifreler oluşturun ve otomatik doldurma ile hızlıca giriş yapın.',
                          features: [
                            'Sınırsız şifre saklama',
                            'Güçlü şifre oluşturucu',
                            'Otomatik doldurma özelliği',
                          ],
                          iconAsset:
                              'assets/elements/second_paywall_mounth_key.png',
                        ),
                      ),
                      _buildIconCircle(
                        assetPath:
                            'assets/elements/second_paywall_mounth_device.png',
                        isYearly: false,
                        onTap: () => _showFeaturePopup(
                          title: '2 Cihaz Senkronizasyonu',
                          description:
                              'Şifreleriniz telefon ve bilgisayarınızda gerçek zamanlı olarak senkronize edilir. Cross-platform desteği ile iOS, Android ve masaüstünde sorunsuz çalışır.',
                          features: [
                            'Telefon ve bilgisayar desteği',
                            'Gerçek zamanlı senkronizasyon',
                            'Cross-platform uyumluluk',
                          ],
                          iconAsset:
                              'assets/elements/second_paywall_mounth_device.png',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIconCircle(
                        assetPath:
                            'assets/elements/second_paywall_fingerprint.png',
                        isYearly: false,
                        onTap: () => _showFeaturePopup(
                          title: 'Biyometrik Güvenlik',
                          description:
                              'Parmak izi ve yüz tanıma ile şifrelerinize hızlı ve güvenli erişim. Ekstra koruma katmanı ile hesabınızı daha da güvenli hale getirin.',
                          features: [
                            'Parmak izi ile giriş',
                            'Yüz tanıma desteği',
                            'Ekstra koruma katmanı',
                          ],
                          iconAsset:
                              'assets/elements/second_paywall_fingerprint.png',
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                '19.99 ₺',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4, left: 4),
                                child: Text(
                                  'per_month'.tr(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──── YEARLY PLAN CARD ────
  Widget _buildYearlyCard() {
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = SecondPaywallPlan.yearly),
      child: Stack(
        children: [
          Container(
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _magentaPink,
                width: 2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _magentaPink.withValues(alpha: 0.2),
                  const Color(0xFF2A1B3D).withValues(alpha: 0.4),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _magentaPink.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'yearly'.tr().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'full_protection'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Icons - 2x2 grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIconCircle(
                            assetPath:
                                'assets/elements/second_paywall_yearly_guard.png',
                            isYearly: true,
                            onTap: () => _showFeaturePopup(
                              title: 'Gelişmiş Güvenlik Denetimi',
                              description:
                                  'Parolalarınızın gücünü analiz edin ve sızıntılara karşı gerçek zamanlı koruma sağlayın. Verileriniz Passora\'nın askeri düzeyde şifreleme altyapısı ile her zaman güvende.',
                              features: [
                                'Zayıf şifre tespiti ve uyarıları',
                                'Dark web sızıntı takibi',
                                'Otomatik şifre yenileme önerileri',
                              ],
                              iconAsset:
                                  'assets/elements/second_paywall_yearly_guard.png',
                            ),
                          ),
                          _buildIconCircle(
                            assetPath:
                                'assets/elements/second_paywall_yearly_cloude.png',
                            isYearly: true,
                            onTap: () => _showFeaturePopup(
                              title: 'Bulut Senkronizasyonu',
                              description:
                                  'Tüm cihazlarınızda anlık senkronizasyon ile şifrelerinize her yerden erişin. 256-bit SSL şifreleme ile verileriniz güvende kalır ve otomatik yedekleme ile hiçbir veri kaybı yaşamazsınız.',
                              features: [
                                'Tüm cihazlarda anlık senkronizasyon',
                                '256-bit SSL şifreleme ile güvenlik',
                                'Otomatik yedekleme ve kurtarma',
                              ],
                              iconAsset:
                                  'assets/elements/second_paywall_yearly_cloude.png',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildIconCircle(
                            assetPath:
                                'assets/elements/second_paywall_yearly_person.png',
                            isYearly: true,
                            onTap: () => _showFeaturePopup(
                              title: 'Sınırsız Kullanıcı Profili',
                              description:
                                  'Aile üyeleriniz için ayrı profiller oluşturun ve kişiselleştirilmiş deneyimin keyfini çıkarın. Paylaşımlı güvenli kasalar ile önemli bilgileri güvenle paylaşın.',
                              features: [
                                'Aile üyeleri için ayrı profiller',
                                'Kişiselleştirilmiş kullanıcı deneyimi',
                                'Paylaşımlı güvenli kasalar',
                              ],
                              iconAsset:
                                  'assets/elements/second_paywall_yearly_person.png',
                            ),
                          ),
                          _buildIconCircle(
                            assetPath:
                                'assets/elements/second_paywall_yearly_star.png',
                            isYearly: true,
                            onTap: () => _showFeaturePopup(
                              title: 'Öncelikli Destek',
                              description:
                                  '7/24 canlı destek ile her zaman yanınızdayız. Özel müşteri temsilciniz ile hızlı çözüm alın. Hızlı yanıt garantisi ile sorunlarınız anında çözülür.',
                              features: [
                                '7/24 canlı destek hattı',
                                'Özel müşteri temsilcisi',
                                'Hızlı yanıt garantisi',
                              ],
                              iconAsset:
                                  'assets/elements/second_paywall_yearly_star.png',
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.bottomLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    '119.99 ₺',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                                    child: Text(
                                      'per_year'.tr(),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Discount badge
          Positioned(
            top: 12,
            right: 12,
            child: Image.asset(
              'assets/elements/second_paywall_%50indirim.png',
              width: 90,
              height: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ──── ICON CIRCLE BUILDER ────
  Widget _buildIconCircle({
    required String assetPath,
    required bool isYearly,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isYearly
              ? LinearGradient(
                  colors: [
                    _magentaPink.withValues(alpha: 0.3),
                    _magentaPink.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: isYearly ? null : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: isYearly
                ? _magentaPink.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 34,
            height: 34,
          ),
        ),
      ),
    );
  }

  // ──── FEATURE HIGHLIGHTS ────
  Widget _buildFeatureHighlights() {
    return Column(
      children: [
        _buildFeatureRow(
          Icons.shield_outlined,
          'military_grade_encryption',
        ),
        const SizedBox(height: 12),
        _buildFeatureRow(
          Icons.sync,
          'instant_sync_devices',
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: _magentaPink, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text.tr(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ──── CTA BUTTON ────
  Widget _buildMainCTAButton() {
    return GestureDetector(
      onTap: _onContinue,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_magentaPink, _magentaPinkLight],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _magentaPink.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          'unlock_all_features_now'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ──── DISCLAIMER ────
  Widget _buildDisclaimer() {
    return Center(
      child: Text(
        'auto_renews_yearly'.tr(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 12,
        ),
      ),
    );
  }

  // ──── POP-UP DIALOG ────
  void _showFeaturePopup({
    required String title,
    required String description,
    required List<String> features,
    required String iconAsset,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => _FeaturePopupDialog(
        title: title,
        description: description,
        features: features,
        iconAsset: iconAsset,
      ),
    );
  }

  // ──── CONTINUE TO PAYMENT ────
  void _onContinue() {
    final planName = _selectedPlan == SecondPaywallPlan.yearly
        ? 'Yıllık Tam Koruma'
        : 'Aylık Başlangıç';
    final price = _selectedPlan == SecondPaywallPlan.yearly
        ? '119.99 ₺/yıl'
        : '19.99 ₺/ay';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecondPaywallPaymentScreen(
          planName: planName,
          price: price,
          isYearly: _selectedPlan == SecondPaywallPlan.yearly,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// FEATURE POPUP DIALOG
// ════════════════════════════════════════════════════════════════════════════════

class _FeaturePopupDialog extends StatelessWidget {
  final String title;
  final String description;
  final List<String> features;
  final String iconAsset;

  const _FeaturePopupDialog({
    required this.title,
    required this.description,
    required this.features,
    required this.iconAsset,
  });

  static const Color _magentaPink = Color(0xFFE91E63);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D1748), Color(0xFF4A3068)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header with close button ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'feature'.tr().toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Icon with gradient border circle ──
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFF6B35),
                          _magentaPink,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1F1535),
                      ),
                      child: Center(
                        child: Image.asset(
                          iconAsset,
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Title ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Description ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Feature list with checkmarks ──
                  ...features.map((feature) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/elements/second_paywall_pop_up_small_okey.png',
                              width: 22,
                              height: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 28),

                  // ── "Anladım" button ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_magentaPink, Color(0xFFF06292)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: _magentaPink.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Text(
                          'understood'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
}
