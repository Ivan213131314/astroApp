import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import '../../theme/theme.dart';

class MasterCardScreen extends StatefulWidget {
  const MasterCardScreen({super.key});

  @override
  State<MasterCardScreen> createState() => _MasterCardScreenState();
}

class _MasterCardScreenState extends State<MasterCardScreen> {
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                getTranslation(context, 'master_card.payment_method'),
                style: bold18White,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          creditCard(size),
          creditCardFields(),
          heightSpace,
          heightSpace,
          heightSpace,
          heightSpace,
          continueButton(),
          heightSpace,
          heightSpace,
        ],
      ),
    );
  }

  continueButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/success');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
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
          getTranslation(context, 'master_card.continue'),
          style: bold20White,
        ),
      ),
    );
  }

  creditCardFields() {
    return CreditCardForm(
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cardHolderName: cardHolderName,
      cvvCode: cvvCode,
      obscureCvv: true,
      formKey: formKey,
      inputConfiguration: InputConfiguration(
        cardHolderTextStyle: medium16WhiteF4,
        cvvCodeTextStyle: medium16WhiteF4,
        cardNumberTextStyle: medium16WhiteF4,
        expiryDateTextStyle: medium16WhiteF4,
        cardHolderDecoration: InputDecoration(
          border: InputBorder.none,
          hintText:
              getTranslation(context, 'master_card.enter_cardholder_name'),
          hintStyle: medium16Grey,
          labelText: getTranslation(context, 'master_card.name_on_card'),
          labelStyle: medium16Grey,
          filled: true,
          fillColor: recBgColor,
          alignLabelWithHint: true,
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        cardNumberDecoration: InputDecoration(
          border: InputBorder.none,
          hintText: getTranslation(context, 'master_card.enter_number'),
          hintStyle: medium16Grey,
          labelText: getTranslation(context, 'master_card.card_number'),
          labelStyle: medium16Grey,
          filled: true,
          fillColor: recBgColor,
          alignLabelWithHint: true,
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        cvvCodeDecoration: InputDecoration(
          border: InputBorder.none,
          hintText: getTranslation(context, 'master_card.cvv'),
          hintStyle: medium16Grey,
          labelText: getTranslation(context, 'master_card.cvv'),
          labelStyle: medium16Grey,
          filled: true,
          fillColor: recBgColor,
          alignLabelWithHint: true,
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        expiryDateDecoration: InputDecoration(
          hintText: getTranslation(context, 'master_card.expire_date'),
          hintStyle: medium16Grey,
          labelText: getTranslation(context, 'master_card.expire_date'),
          labelStyle: medium16Grey,
          filled: true,
          fillColor: recBgColor,
          alignLabelWithHint: true,
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
      onCreditCardModelChange: (CreditCardModel creditCardModel) {
        setState(() {
          cardNumber = creditCardModel.cardNumber;
          expiryDate = creditCardModel.expiryDate;
          cardHolderName = creditCardModel.cardHolderName;
          cvvCode = creditCardModel.cvvCode;
          isCvvFocused = creditCardModel.isCvvFocused;
        });
      },
    );
  }

  creditCard(Size size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: CreditCardWidget(
        padding: 20.0,
        height: size.height * 0.3,
        bankName: getTranslation(context, 'master_card.credit_card'),
        backgroundImage: "assets/creditCard/bgImage.png",
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cardType: CardType.mastercard,
        cardHolderName: cardHolderName,
        cvvCode: cvvCode,
        showBackView: isCvvFocused,
        isHolderNameVisible: true,
        cardBgColor: scaffoldBgColor,
        isChipVisible: false,
        obscureCardCvv: true,
        obscureCardNumber: true,
        customCardTypeIcons: [
          CustomCardTypeIcon(
            cardType: CardType.mastercard,
            cardImage: Image.asset(
              "assets/creditCard/cardLogo.png",
              fit: BoxFit.contain,
              height: 30,
              width: 50,
            ),
          ),
        ],
        onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
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
