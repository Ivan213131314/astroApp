import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class PlamReaderScreen extends StatefulWidget {
  const PlamReaderScreen({super.key});

  @override
  State<PlamReaderScreen> createState() => _PlamReaderScreenState();
}

class _PlamReaderScreenState extends State<PlamReaderScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: backButton(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(fixPadding * 2.0),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            getTranslation(context, 'plam_reader.take_photo_hand'),
            style: medium22WhiteF4,
            textAlign: TextAlign.center,
          ),
          height5Space,
          const Text(
            "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris atlaoreet quam. Cursus risus nisl nulla et magna ",
            style: regualr14Grey,
            textAlign: TextAlign.center,
          ),
          heightBox(size.height * 0.11),
          image(size),
          heightBox(size.height * 0.11),
          takePhotoButton()
        ],
      ),
    );
  }

  image(Size size) {
    return Center(
      child: Container(
        height: size.height * 0.3,
        width: size.height * 0.3,
        decoration: const BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage("assets/plamreader/handImage.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  takePhotoButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/plamReaderDetail');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding * 1.2, horizontal: fixPadding * 2.0),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.25),
              blurRadius: 6,
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'plam_reader.take_photo'),
          style: bold20White,
        ),
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
