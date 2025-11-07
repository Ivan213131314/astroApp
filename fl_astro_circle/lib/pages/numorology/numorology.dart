import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';

class NumorologyScreen extends StatefulWidget {
  const NumorologyScreen({super.key});

  @override
  State<NumorologyScreen> createState() => _NumorologyScreenState();
}

class _NumorologyScreenState extends State<NumorologyScreen> {
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20.0,
        title: backButton(context),
      ),
      body: Stack(
        children: [
          bgImage(size),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
            physics: const BouncingScrollPhysics(),
            children: [
              heightSpace,
              heightSpace,
              numorologyText(),
              heightSpace,
              numberEffectText(),
              heightSpace,
              detailText(),
              heightSpace,
              heightSpace,
              height5Space,
              selectDateText(),
              heightSpace,
              heightSpace,
              datePicker(size),
              heightSpace,
              heightSpace,
              height5Space,
              goButton()
            ],
          ),
        ],
      ),
    );
  }

  bgImage(Size size) {
    return Container(
      height: size.height,
      width: size.width,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.maxFinite,
        height: size.height * 0.22,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/numorology/bgimage.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scaffoldBgColor,
                scaffoldBgColor.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  numberEffectText() {
    return Text(
      getTranslation(context, 'numorology.number_effect'),
      style: regualr16Grey,
      textAlign: TextAlign.center,
    );
  }

  detailText() {
    return const Text(
      "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh",
      style: regualr14Grey,
      textAlign: TextAlign.center,
    );
  }

  numorologyText() {
    return Text(
      getTranslation(context, 'numorology.numorology'),
      style: bold20White,
      textAlign: TextAlign.center,
    );
  }

  selectDateText() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding, horizontal: fixPadding * 2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: primaryColor,
          boxShadow: [
            BoxShadow(
              color: recBgColor.withValues(alpha: 0.25),
              blurRadius: 6,
            )
          ],
        ),
        child: Text(
          getTranslation(context, 'numorology.select_date'),
          style: bold20White,
        ),
      ),
    );
  }

  datePicker(Size size) {
    return SizedBox(
      height: size.height * 0.28,
      width: double.maxFinite,
      child: ScrollDatePicker(
        options: const DatePickerOptions(
          backgroundColor: scaffoldBgColor,
        ),
        scrollViewOptions: const DatePickerScrollViewOptions(
          day: ScrollViewDetailOptions(
            selectedTextStyle: bold20Primary,
            textStyle: bold16WhiteF4,
          ),
          month: ScrollViewDetailOptions(
            selectedTextStyle: bold20Primary,
            textStyle: bold16WhiteF4,
          ),
          year: ScrollViewDetailOptions(
              selectedTextStyle: bold20Primary,
              textStyle: bold16WhiteF4,
              margin: EdgeInsets.symmetric(horizontal: fixPadding)),
        ),
        selectedDate: selectedDate,
        onDateTimeChanged: (date) {
          setState(() {
            selectedDate = date;
          });
        },
      ),
    );
  }

  goButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/numorologyDetail');
      },
      child: Container(
        padding: const EdgeInsets.all(fixPadding * 1.2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor,
          border: Border.all(color: whiteColor, width: 5),
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'numorology.go'),
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
