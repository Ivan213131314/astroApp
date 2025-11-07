import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';

import '../../theme/theme.dart';

class NatalChartScreen extends StatefulWidget {
  const NatalChartScreen({super.key});

  @override
  State<NatalChartScreen> createState() => _NatalChartScreenState();
}

class _NatalChartScreenState extends State<NatalChartScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController timeofBirthController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  DateTime selectedTime = DateTime.now();

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
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            backButton(context),
            widthSpace,
            width5Space,
            Expanded(
              child: Text(
                getTranslation(context, 'natal_chart.natal_chart'),
                style: bold18White,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: fixPadding * 2.0,
          right: fixPadding * 2.0,
          bottom: fixPadding * 2.0,
          top: fixPadding,
        ),
        children: [
          natalTitle(),
          heightSpace,
          contentText(),
          heightSpace,
          heightSpace,
          heightSpace,
          nameField(),
          heightSpace,
          heightSpace,
          dateOfBirthField(size),
          heightSpace,
          heightSpace,
          timeOfBirthField(size),
          heightSpace,
          heightSpace,
          locationField(),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          calculateButton(),
        ],
      ),
    );
  }

  contentText() {
    return const Text(
      "Lorem ipsum dolor sit amet consectetur. In vitae in volutpat eu lectus. Eget aliquet pharetra nunc lacus. Mauris at mattis laoreet quam. Cursus risus nisl nulla et magna maecenasid id. Enim nibh quisque tellus urna justo. Egestas id pharetrah morbi quam in eu. Mattis mattis odio velit volutpat blandit a pellentesque scelerisque vestibulum eget pulvinar. Eu sit gh ",
      style: regualr14Grey,
      textAlign: TextAlign.center,
    );
  }

  natalTitle() {
    return Text(
      getTranslation(context, 'natal_chart.title'),
      style: medium18White,
      textAlign: TextAlign.center,
    );
  }

  calculateButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/natalchartDetail');
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
              blurRadius: 5,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'natal_chart.calculate'),
          style: bold20White,
        ),
      ),
    );
  }

  locationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText(getTranslation(context, 'natal_chart.birth_location')),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: recBgColor,
            boxShadow: [
              BoxShadow(
                color: recBgColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: medium15WhiteF4,
            cursorColor: primaryColor,
            controller: locationController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
              border: InputBorder.none,
              hintText:
                  getTranslation(context, 'natal_chart.enter_birth_location'),
              hintStyle: regualr15Grey,
            ),
          ),
        )
      ],
    );
  }

  timeOfBirthField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText(getTranslation(context, 'natal_chart.time_of_birth')),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: recBgColor,
            boxShadow: [
              BoxShadow(
                color: recBgColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            onTap: () {
              timePickerDialog(size);
            },
            readOnly: true,
            style: medium15WhiteF4,
            controller: timeofBirthController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0,
                vertical: fixPadding * 1.4,
              ),
              border: InputBorder.none,
              hintText: getTranslation(context, 'natal_chart.select_time'),
              hintStyle: regualr15Grey,
            ),
          ),
        )
      ],
    );
  }

  timePickerDialog(Size size) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, state) {
              return Dialog(
                backgroundColor: whiteColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                insetPadding: const EdgeInsets.all(fixPadding * 2.0),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: fixPadding * 2.0),
                      child: Text(
                        getTranslation(context, 'natal_chart.time'),
                        style: bold20BlueShade1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: 1,
                      width: double.maxFinite,
                      color: greyD4Color,
                    ),
                    heightSpace,
                    SizedBox(
                      height: size.height * 0.22,
                      child: CupertinoTheme(
                        data: const CupertinoThemeData(
                          textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: bold20Primary),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: selectedTime,
                          onDateTimeChanged: (date) {
                            setState(
                              () {
                                selectedTime = date;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    heightSpace,
                    heightSpace,
                    proceedButton(
                      () {
                        setState(() {
                          String formattedTime = DateFormat.jm(
                                  Localizations.localeOf(context).toString())
                              .format(selectedTime);
                          timeofBirthController.text = formattedTime;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    height5Space,
                    cancelButton(context),
                    height5Space,
                  ],
                ),
              );
            },
          );
        });
  }

  dateOfBirthField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText(getTranslation(context, 'natal_chart.date_birth')),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: recBgColor,
            boxShadow: [
              BoxShadow(
                color: recBgColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: medium15WhiteF4,
            controller: dobController,
            onTap: () {
              datePickerDialog(size);
            },
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
              border: InputBorder.none,
              hintText: getTranslation(context, 'natal_chart.select_date'),
              hintStyle: regualr15Grey,
            ),
          ),
        )
      ],
    );
  }

  datePickerDialog(Size size) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, state) {
            return Dialog(
              backgroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              insetPadding: const EdgeInsets.all(fixPadding * 2.0),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: fixPadding * 2.0),
                    child: Text(
                      getTranslation(context, 'natal_chart.date'),
                      style: bold20BlueShade1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    height: 1,
                    width: double.maxFinite,
                    color: greyD4Color,
                  ),
                  heightSpace,
                  SizedBox(
                    height: size.height * 0.22,
                    child: ScrollDatePicker(
                      selectedDate: selectedDate,
                      scrollViewOptions: const DatePickerScrollViewOptions(
                        day: ScrollViewDetailOptions(
                          selectedTextStyle: bold20Primary,
                          textStyle: bold18BlueShade1,
                        ),
                        month: ScrollViewDetailOptions(
                          selectedTextStyle: bold20Primary,
                          textStyle: bold18BlueShade1,
                        ),
                        year: ScrollViewDetailOptions(
                            selectedTextStyle: bold20Primary,
                            textStyle: bold18BlueShade1,
                            margin: EdgeInsets.symmetric(
                                horizontal: fixPadding * 2.0)),
                      ),
                      onDateTimeChanged: (date) {
                        state(() {
                          setState(
                            () {
                              selectedDate = date;
                            },
                          );
                        });
                      },
                    ),
                  ),
                  heightSpace,
                  heightSpace,
                  proceedButton(
                    () {
                      setState(() {
                        String formattedDate =
                            DateFormat('dd MMMM yyyy').format(selectedDate);

                        dobController.text = formattedDate;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  height5Space,
                  cancelButton(context),
                  height5Space,
                ],
              ),
            );
          },
        );
      },
    );
  }

  cancelButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        getTranslation(context, 'natal_chart.cancel'),
        style: bold16Grey,
      ),
    );
  }

  proceedButton(Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: primaryColor,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.25),
              blurRadius: 6,
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          getTranslation(context, 'natal_chart.proceed'),
          style: bold20White,
        ),
      ),
    );
  }

  nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText(getTranslation(context, 'natal_chart.name')),
        heightSpace,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: recBgColor,
            boxShadow: [
              BoxShadow(
                color: recBgColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: medium15WhiteF4,
            cursorColor: primaryColor,
            controller: nameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: fixPadding * 2.0, vertical: fixPadding * 1.4),
              border: InputBorder.none,
              hintText: getTranslation(context, 'natal_chart.enter_name'),
              hintStyle: regualr15Grey,
            ),
          ),
        )
      ],
    );
  }

  titleText(String text) {
    return Text(
      text,
      style: bold16WhiteF4,
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
