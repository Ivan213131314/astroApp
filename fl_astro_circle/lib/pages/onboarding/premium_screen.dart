import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.86);

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
      note: 'Auto-renewable',
    ),
    _PlanOption(
      title: 'Yearly',
      price: '\$37.89',
      billedAs: 'BILLED\nANNUALLY',
      note: 'Auto-renewable',
      isPopular: true,
    ),
    _PlanOption(
      title: 'Monthly',
      price: '\$39.99',
      billedAs: 'BILLED\nMONTHLY',
      note: 'Auto-renewable',
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

    return Scaffold(
      backgroundColor: const Color(0xFF09051A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF120B34),
              Color(0xFF09051A),
              Color(0xFF140B33),
            ],
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
                      24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 34,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTopBar(),
                          const SizedBox(height: 20),
                          Text(
                            'Unlock Cosmic\nWisdom',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: size.width < 360 ? 30 : 34,
                              fontWeight: FontWeight.w800,
                              height: 1.04,
                              letterSpacing: -1.2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFeatureCarousel(size),
                          const SizedBox(height: 12),
                          _buildFeatureIndicators(),
                          const SizedBox(height: 22),
                          _buildPlanRow(),
                          const SizedBox(height: 24),
                          _buildCtaButton(),
                          const SizedBox(height: 14),
                          _buildTrustRow(),
                          const SizedBox(height: 8),
                          const Text(
                            'Subscription is optional and auto-renewable.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF7B7793),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: whiteColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Restore Purchase',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 1.5,
                                  color: whiteColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: const [
                              Expanded(
                                child: _FooterLink(
                                  label: 'Terms of\nService',
                                  routeName: '/termsOfService',
                                ),
                              ),
                              Expanded(
                                child: _FooterLink(
                                  label: 'Privacy\nPolicy',
                                  routeName: '/privacyPolicy',
                                ),
                              ),
                              Expanded(
                                child: _FooterLink(
                                  label: 'Subscription\nTerms',
                                  routeName: '/subscriptionTerms',
                                ),
                              ),
                            ],
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
            color: Color(0xFFD3D0E1),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCarousel(Size size) {
    final height = size.width < 360 ? 138.0 : 156.0;

    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _features.length,
        onPageChanged: (index) {
          setState(() {
            _selectedFeatureIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final feature = _features[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
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
            width: isSelected ? 12 : 8,
            height: isSelected ? 12 : 8,
            decoration: BoxDecoration(
              color: isSelected ? whiteColor : const Color(0xFF4B4962),
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
                left: index == 0 ? 0 : 6,
                right: index == _plans.length - 1 ? 0 : 6,
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
      borderRadius: BorderRadius.circular(24),
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 82,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFF7BC1D),
              Color(0xFFFF8F08),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFA30D).withValues(alpha: 0.30),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'Continue',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF140D20),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
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
          Icons.verified_rounded,
          color: Color(0xFF41D46F),
          size: 20,
        ),
        SizedBox(width: 10),
        Flexible(
          child: Text(
            'Secured by Visa App Store',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFE4E2ED),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
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
      borderRadius: BorderRadius.circular(28),
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
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1.2,
              ),
            ),
          ),
          Positioned(
            left: 28,
            right: 28,
            bottom: 24,
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
                const SizedBox(height: 6),
                Text(
                  feature.subtitle,
                  style: const TextStyle(
                    color: Color(0xFFE1DFEA),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
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
        final compact = constraints.maxWidth < 100;
        final borderColor = isSelected
            ? const Color(0xFFAA52FF)
            : Colors.white.withValues(alpha: 0.12);
        final backgroundColor = isSelected
            ? const Color(0xFF1D173D)
            : Colors.white.withValues(alpha: 0.03);

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                height: compact ? 162 : 176,
                padding: EdgeInsets.fromLTRB(
                  compact ? 8 : 10,
                  plan.isPopular ? (compact ? 18 : 20) : (compact ? 12 : 14),
                  compact ? 8 : 10,
                  compact ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected ? 2.5 : 1.3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFFAA52FF,
                            ).withValues(alpha: 0.28),
                            blurRadius: 22,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      plan.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFAFACC2),
                        fontSize: compact ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: compact ? 1.4 : 1.8,
                      ),
                    ),
                    SizedBox(height: compact ? 8 : 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              plan.price,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: compact ? 18 : 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 8 : 10),
                          Text(
                            plan.billedAs,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFB8B5C9),
                              fontSize: compact ? 8.5 : 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      plan.note.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? whiteColor : const Color(0xFF6E6B84),
                        fontSize: compact ? 8.5 : 10,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 16 : 22,
                    vertical: compact ? 7 : 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF5C53),
                        Color(0xFFFF7A1B),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6C3A).withValues(alpha: 0.28),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: compact ? 10 : 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.label,
    required this.routeName,
  });

  final String label;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, routeName),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF85829A),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF85829A),
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          height: 1.5,
        ),
      ),
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
          top: -90,
          left: -40,
          child: _Glow(
            size: 230,
            color: const Color(0xFF6B3EF7).withValues(alpha: 0.18),
          ),
        ),
        Positioned(
          top: 320,
          right: -40,
          child: _Glow(
            size: 160,
            color: const Color(0xFF1190FF).withValues(alpha: 0.10),
          ),
        ),
        Positioned(
          bottom: 80,
          left: -70,
          child: _Glow(
            size: 220,
            color: const Color(0xFFFFA114).withValues(alpha: 0.08),
          ),
        ),
        const _BackgroundDot(top: 118, left: 102, size: 3),
        const _BackgroundDot(top: 366, right: 126, size: 8),
        const _BackgroundDot(top: 522, left: 166, size: 3),
        const _BackgroundDot(top: 604, right: 62, size: 6),
        const _BackgroundDot(top: 782, left: 82, size: 3),
        const _BackgroundDot(top: 912, right: 94, size: 3),
        const _BackgroundDot(bottom: 128, left: 132, size: 4),
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
          color: Colors.white.withValues(alpha: 0.85),
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
