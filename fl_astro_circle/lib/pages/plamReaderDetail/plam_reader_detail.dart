import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/services/palm_reading_service.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class PlamReaderDetailScreen extends StatefulWidget {
  const PlamReaderDetailScreen({super.key});

  @override
  State<PlamReaderDetailScreen> createState() => _PlamReaderDetailScreenState();
}

class _PlamReaderDetailScreenState extends State<PlamReaderDetailScreen> {
  PalmReadingResult? _result;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _result = args?['result'] as PalmReadingResult?;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_result == null) {
      return const Scaffold(
        backgroundColor: scaffoldBgColor,
        body: Center(
          child: Text('Error: No data', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: blueShade1,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            expandedHeight: 330,
            backgroundColor: scaffoldBgColor,
            elevation: 0,
            titleSpacing: 20.0,
            centerTitle: false,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                backButton(context),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: plamInfo(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(fixPadding * 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      detailWidget(
                        getTranslation(context, 'plam_reader_detail.life_line'),
                        _result!.lifeLine,
                      ),
                      heightSpace,
                      heightSpace,
                      detailWidget(
                        getTranslation(context, 'plam_reader_detail.heart_line'),
                        _result!.heartLine,
                      ),
                      heightSpace,
                      heightSpace,
                      detailWidget(
                        getTranslation(context, 'plam_reader_detail.money_line'),
                        _result!.moneyLine,
                      ),
                      heightSpace,
                      heightSpace,
                      detailWidget(
                        getTranslation(context, 'plam_reader_detail.health_line'),
                        _result!.healthLine,
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  detailWidget(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: medium18White,
        ),
        height5Space,
        Container(
          height: 5,
          width: 45,
          color: primaryColor,
        ),
        heightSpace,
        // Paywall: градиент с первой строки, blur со второй, замок по центру
        _buildPaywallContent(content),
      ],
    );
  }

  Widget _buildPaywallContent(String content) {
    return GestureDetector(
      onTap: () {
        // TODO: Логика покупок будет добавлена позже
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Первая строка с градиентом (видно частично)
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.3),
                    ],
                    stops: const [0.0, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Text(
                  content,
                  style: regualr14Grey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              // Вторая+ строки с blur + сильный градиент
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Text(
                    content,
                    style: regualr14Grey,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          // Иконка замочка по центру
          Positioned(
            child: Icon(
              Icons.lock,
              color: primaryColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  plamInfo() {
    return Padding(
      padding: const EdgeInsets.only(
          left: fixPadding * 2, right: fixPadding * 2.0, top: fixPadding * 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            getTranslation(context, 'plam_reader_detail.personal_analysis'),
            style: medium22WhiteF4,
            textAlign: TextAlign.center,
          ),
          heightSpace,
          heightSpace,
          Container(
            height: 185,
            width: 185,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 3),
            ),
            child: ClipOval(
              child: _result?.imageBase64 != null
                  ? Image.memory(
                      base64Decode(_result!.imageBase64!),
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.back_hand,
                      size: 100,
                      color: whiteColor,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  backButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: recBgColor,
        ),
        child: const Icon(
          Icons.arrow_back,
          color: whiteColor,
          size: 22,
        ),
      ),
    );
  }
}
