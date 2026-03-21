import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.84);

  final List<_PaywallFeature> _features = const [
    _PaywallFeature(
      title: 'Natal Chart',
      subtitle: 'Understand your cosmic blueprint',
      image: 'assets/home/natal_chart_premium.png',
    ),
    _PaywallFeature(
      title: 'Compatibility',
      subtitle: 'Sync with the people around you',
      image: 'assets/home/compatibility_premium.png',
    ),
    _PaywallFeature(
      title: 'Numerology',
      subtitle: 'Decode the numbers guiding your path',
      image: 'assets/home/numerology_premium.png',
    ),
    _PaywallFeature(
      title: 'Palm Reading',
      subtitle: 'Reveal the signs written in your hands',
      image: 'assets/home/palm_reading_premium.png',
    ),
  ];

  final List<_PlanOption> _plans = const [
    _PlanOption(
      title: 'Weekly',
      price: '\$7.99',
      billedAs: 'BILLED\nWEEKLY',
      note: 'AUTO-RENEWABLE',
    ),
    _PlanOption(
      title: 'Yearly',
      price: '\$37.99',
      billedAs: 'BILLED\nANNUALLY',
      note: 'AUTO-RENEWABLE',
      isPopular: true,
    ),
    _PlanOption(
      title: '3 Month',
      price: '\$39.99',
      billedAs: 'BILLED EVERY 3\nMONTH',
      note: 'AUTO-RENEWABLE',
    ),
  ];

  int _selectedFeatureIndex = 0;
  int _selectedPlanIndex = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontalPadding = size.width < 360 ? 16.0 : 20.0;
    final titleSize = size.width < 360 ? 30.0 : 34.0;

    return Scaffold(
      backgroundColor: const Color(0xFF090515),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF130A33),
              Color(0xFF090515),
              Color(0xFF12091F),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  const Positioned.fill(
                    child: IgnorePointer(child: _PaywallBackground()),
                  ),
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      10,
                      horizontalPadding,
                      18,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTopBar(),
                          SizedBox(height: size.height < 780 ? 24 : 36),
                          Text(
                            'Unlock\nAstro Circle',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              letterSpacing: -1.3,
                            ),
                          ),
                          SizedBox(height: size.height < 780 ? 26 : 34),
                          _buildFeatureCarousel(size),
                          const SizedBox(height: 18),
                          _buildFeatureIndicators(),
                          const SizedBox(height: 34),
                          _buildPlanRow(),
                          const SizedBox(height: 34),
                          _buildCtaButton(),
                          const SizedBox(height: 28),
                          _buildTrustRow(),
                          const SizedBox(height: 10),
                          const Text(
                            'subscription is optional and auto-renewable. Cancel anytime.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF726D88),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 38),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: whiteColor,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text(
                              'Restore Purchase',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xCCFFFFFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pop(context),
        child: const Padding(
          padding: EdgeInsets.only(top: 4, right: 10, bottom: 4),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFD4D1E2),
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCarousel(Size size) {
    final height = size.width < 360 ? 170.0 : 184.0;

    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _features.length,
        padEnds: false,
        onPageChanged: (index) {
          setState(() {
            _selectedFeatureIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final feature = _features[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == _features.length - 1 ? 0 : 12,
            ),
            child: _FeatureCard(feature: feature),
          );
        },
      ),
    );
  }

  Widget _buildFeatureIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _features.length,
        (index) {
          final isSelected = index == _selectedFeatureIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isSelected ? 10 : 7,
            height: isSelected ? 10 : 7,
            decoration: BoxDecoration(
              color: isSelected ? whiteColor : const Color(0xFF5A576B),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        _plans.length,
        (index) {
          final plan = _plans[index];
          final isSelected = index == _selectedPlanIndex;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 7,
                right: index == _plans.length - 1 ? 0 : 7,
              ),
              child: _PlanCard(
                plan: plan,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedPlanIndex = index;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCtaButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(34),
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFF7B700),
              Color(0xFFFF8F08),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB000).withValues(alpha: 0.32),
              blurRadius: 28,
              spreadRadius: 3,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'START MY JOURNEY',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0A1020),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTrustRow() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF36D36E),
          size: 18,
        ),
        SizedBox(width: 8),
        Text(
          'Secured with App Store.',
          style: TextStyle(
            color: Color(0xFFD8D5E6),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _PaywallFeature feature;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            feature.image,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.22),
                  Colors.black.withValues(alpha: 0.40),
                  Colors.black.withValues(alpha: 0.68),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1.2,
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    color: whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.subtitle,
                  style: const TextStyle(
                    color: Color(0xFFD8D5E6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final _PlanOption plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 110;
        final borderColor = isSelected
            ? const Color(0xFFA654FF)
            : Colors.white.withValues(alpha: 0.10);

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                height: compact ? 156 : 164,
                padding: EdgeInsets.fromLTRB(
                  compact ? 10 : 12,
                  plan.isPopular ? 20 : 16,
                  compact ? 10 : 12,
                  compact ? 12 : 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF25184F),
                            Color(0xFF17122E),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.04),
                            Colors.white.withValues(alpha: 0.02),
                          ],
                        ),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF8E44FF).withValues(alpha: 0.22),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      plan.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFA8A4BD),
                        fontSize: compact ? 11 : 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        plan.price,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: compact ? 24 : 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      plan.billedAs,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF8F8AA8),
                        fontSize: compact ? 11 : 12,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      plan.note,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFE7E3F5)
                            : const Color(0xFF74708A),
                        fontSize: compact ? 9.5 : 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (plan.isPopular)
              Positioned(
                top: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFFF5B55),
                        Color(0xFFFF8A1D),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF7140).withValues(alpha: 0.28),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'MOST POPULAR',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFFFE1B0),
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PaywallBackground extends StatelessWidget {
  const _PaywallBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -120,
          left: -70,
          child: _Glow(
            size: 260,
            color: const Color(0xFF5B2DE4).withValues(alpha: 0.18),
          ),
        ),
        Positioned(
          top: 170,
          right: -40,
          child: _Glow(
            size: 170,
            color: const Color(0xFF8CC3FF).withValues(alpha: 0.06),
          ),
        ),
        Positioned(
          bottom: -30,
          right: -10,
          child: _Glow(
            size: 220,
            color: const Color(0xFF3B1B8A).withValues(alpha: 0.18),
          ),
        ),
        const _BackgroundDot(top: 104, left: 72, size: 3),
        const _BackgroundDot(top: 260, right: 54, size: 4),
        const _BackgroundDot(top: 468, left: 146, size: 3),
        const _BackgroundDot(top: 676, right: 70, size: 5),
        const _BackgroundDot(top: 882, left: 100, size: 2),
        const _BackgroundDot(top: 516, right: 30, size: 2),
      ],
    );
  }
}

class _BackgroundDot extends StatelessWidget {
  const _BackgroundDot({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
  });

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 8,
          ),
        ],
      ),
    );
  }
}

class _PaywallFeature {
  const _PaywallFeature({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  final String title;
  final String subtitle;
  final String image;
}

class _PlanOption {
  const _PlanOption({
    required this.title,
    required this.price,
    required this.billedAs,
    required this.note,
    this.isPopular = false,
  });

  final String title;
  final String price;
  final String billedAs;
  final String note;
  final bool isPopular;
}
