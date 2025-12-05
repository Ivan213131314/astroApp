import 'dart:convert';
import 'dart:typed_data';
import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/services/palm_reading_service.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

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
        ReadMoreText(
          content,
          style: regualr14Grey,
          moreStyle: regualr14Primary,
          lessStyle: regualr14Primary,
          trimLines: 8,
          trimMode: TrimMode.Line,
          trimExpandedText:
              getTranslation(context, 'plam_reader_detail.show_less'),
          trimCollapsedText:
              getTranslation(context, 'plam_reader_detail.read_more'),
        )
      ],
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
