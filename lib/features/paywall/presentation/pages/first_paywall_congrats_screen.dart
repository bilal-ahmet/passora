import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../shared/widgets/gradient_scaffold.dart';

class FirstPaywallCongratsScreen extends StatefulWidget {
  final String planName;

  const FirstPaywallCongratsScreen({
    super.key,
    required this.planName,
  });

  @override
  State<FirstPaywallCongratsScreen> createState() =>
      _FirstPaywallCongratsScreenState();
}

class _FirstPaywallCongratsScreenState extends State<FirstPaywallCongratsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Paywall color constants
  static const Color _hotPink = Color(0xFFE91E63);
  static const Color _darkPurple = Color(0xFF9C27B0);
  static const Color _goldYellow = Color(0xFFFFD700);
  static const Color _goldYellowDark = Color(0xFFFFC107);
  static const Color _successGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildSuccessAnimation(),
                    const SizedBox(height: 48),
                    _buildSuccessMessage(),
                    const SizedBox(height: 48),
                    _buildActivePlanCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Shield icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_hotPink, _darkPurple],
              ),
            ),
            child: const Center(
              child: Icon(Icons.shield, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Passora',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Radial glow background
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _hotPink.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Decorative dots
            ..._buildDecorativeDots(),

            // Key icon - top right
            Positioned(
              top: 20,
              right: 30,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hotPink.withValues(alpha: 0.2),
                  border: Border.all(
                    color: _hotPink.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.vpn_key,
                    color: _hotPink,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Outer dark circle
            Container(
              width: 200,
              height: 200,
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
                    color: _hotPink.withValues(alpha: 0.25),
                    blurRadius: 60,
                  ),
                ],
              ),
            ),

            // Inner gold checkmark circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_goldYellow, _goldYellowDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _goldYellow.withValues(alpha: 0.4),
                    blurRadius: 80,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/elements/first_paywall_tebrik_okeyi.png',
                  width: 60,
                  height: 60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDecorativeDots() {
    return [
      // Pink dot top-left
      Positioned(
        top: 40,
        left: 40,
        child: _buildDot(16, _hotPink.withValues(alpha: 0.6)),
      ),
      // Small dot top-left
      Positioned(
        top: 80,
        left: 20,
        child: _buildDot(8, _hotPink.withValues(alpha: 0.3)),
      ),
      // Orange dot bottom-left
      Positioned(
        bottom: 60,
        left: 50,
        child: _buildDot(12, const Color(0xFFFF9800).withValues(alpha: 0.5)),
      ),
      // Pink dot bottom
      Positioned(
        bottom: 30,
        right: 60,
        child: _buildDot(10, _hotPink.withValues(alpha: 0.4)),
      ),
      // Small dot right
      Positioned(
        top: 120,
        right: 20,
        child: _buildDot(6, _darkPurple.withValues(alpha: 0.6)),
      ),
    ];
  }

  Widget _buildDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Text(
            'congratulations'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'under_full_protection'.tr(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlanCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left pink accent border
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: _hotPink,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                  // Card content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'active_plan'.tr().toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'yearly_full_protection'.tr(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Active status badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _successGreen.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _successGreen,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'active'.tr().toUpperCase(),
                                        style: const TextStyle(
                                          color: _successGreen,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Star icon
                          Image.asset(
                            'assets/elements/first_paywall_tebrik_yildizi.png',
                            width: 32,
                            height: 32,
                          ),
                        ],
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

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          // Start button
          GestureDetector(
            onTap: _onStart,
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
                    'start_now'.tr(),
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
          ),
          const SizedBox(height: 16),
          // Footer text
          Text(
            'invoice_sent_email'.tr(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _onStart() {
    // Pop all paywall screens and return to settings
    Navigator.of(context).popUntil((route) {
      // Pop until we reach the settings page or the first route
      return route.isFirst || route.settings.name == '/settings';
    });
  }
}
