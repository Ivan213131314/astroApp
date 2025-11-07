import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/widget/column_builder.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final paymentList = [
    {
      "image": "assets/payment/mastercard.png",
      "name": "Mastercard",
      "color": const Color(0xFFCCEFFF)
    },
    {
      "image": "assets/payment/payPal.png",
      "name": "PayPal",
      "color": const Color(0xFFCCDEFF)
    },
    {
      "image": "assets/payment/googlePay.png",
      "name": "Google pay",
      "color": const Color(0xFFCCDEFF)
    },
    {
      "image": "assets/payment/visa.png",
      "name": "Visa card",
      "color": const Color(0xFFD8E3F3)
    },
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        centerTitle: false,
        elevation: 0,
        backgroundColor: scaffoldBgColor,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            backButton(context),
            widthSpace,
            width5Space,
            Expanded(
              child: Text(
                getTranslation(context, 'payment_method.payment_method'),
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
        ),
        children: [
          paymentMethodListContent(),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          continueButton()
        ],
      ),
    );
  }

  continueButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/mastercard');
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0, vertical: fixPadding * 1.2),
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
          getTranslation(context, 'payment_method.continue'),
          style: bold20White,
        ),
      ),
    );
  }

  paymentMethodListContent() {
    return ColumnBuilder(
      itemBuilder: (context, index) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: fixPadding * 2),
                child: Row(
                  children: [
                    Container(
                      height: 24,
                      width: 35,
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        color: paymentList[index]['color'] as Color,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      child: Image.asset(
                        paymentList[index]['image'].toString(),
                      ),
                    ),
                    widthSpace,
                    width5Space,
                    Expanded(
                      child: Text(
                        paymentList[index]['name'].toString(),
                        style: medium16White,
                      ),
                    ),
                    Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedIndex == index
                            ? scaffoldBgColor
                            : recBgColor,
                        border: selectedIndex == index
                            ? Border.all(
                                color: primaryColor,
                                width: 7.5,
                              )
                            : null,
                      ),
                    )
                  ],
                ),
              ),
            ),
            paymentList.length == index + 1
                ? const SizedBox()
                : Container(
                    width: double.maxFinite,
                    height: 1,
                    color: recBgColor,
                  )
          ],
        );
      },
      itemCount: paymentList.length,
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
