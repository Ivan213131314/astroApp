import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class PlaceOfBirthScreen extends StatefulWidget {
  const PlaceOfBirthScreen({super.key});

  @override
  State<PlaceOfBirthScreen> createState() => _PlaceOfBirthScreenState();
}

class _PlaceOfBirthScreenState extends State<PlaceOfBirthScreen> {
  final TextEditingController placeController = TextEditingController();
  final FocusNode placeFocusNode = FocusNode();
  
  // TODO: Замените на ваш Google Places API ключ
  static const String googleApiKey = "AIzaSyA2SREUYbUCxDavUiFaZ1UyKf6XPI7eZ1k";
  
  String? selectedPlaceId;
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    // GooglePlaceAutoCompleteTextField управляет фокусом автоматически
  }

  @override
  void dispose() {
    placeController.dispose();
    placeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Place of birth',
          style: TextStyle(
            color: whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scaffoldBgColor,
              Color(0xFF301B87),
            ],
          ),
        ),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: 0.4,
              backgroundColor: const Color(0xFF3D3761),
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 3,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(fixPadding * 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heightSpace,
                    heightSpace,
                    heightSpace,
                    placeInputField(),
                    heightSpace,
                    heightSpace,
                    const Text(
                      'We will analyze the position of stars and planets in your place of birth at the moment you were born',
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(fixPadding * 2.0),
              child: nextButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget placeInputField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2F2955),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: placeFocusNode.hasFocus ? primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: placeController,
        googleAPIKey: googleApiKey,
        inputDecoration: const InputDecoration(
          hintText: 'Type in your place of birth',
          hintStyle: TextStyle(
            color: greyColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0,
            vertical: fixPadding * 1.2,
          ),
        ),
        textStyle: const TextStyle(
          color: whiteColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        debounceTime: 600,
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          setState(() {
            selectedPlaceId = prediction.placeId;
            latitude = double.tryParse(prediction.lat ?? '');
            longitude = double.tryParse(prediction.lng ?? '');
          });
        },
        itemClick: (Prediction prediction) {
          placeController.text = prediction.description ?? '';
          placeController.selection = TextSelection.fromPosition(
            TextPosition(offset: placeController.text.length),
          );
          placeFocusNode.unfocus();
          setState(() {
            selectedPlaceId = prediction.placeId;
          });
        },
        seperatedBuilder: const Divider(
          color: Color(0xFF3D3761),
          height: 1,
        ),
        containerHorizontalPadding: 0,
        containerVerticalPadding: 0,
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            color: const Color(0xFF2F2955),
            padding: const EdgeInsets.symmetric(
              horizontal: fixPadding * 2.0,
              vertical: fixPadding * 1.2,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: fixPadding),
                Expanded(
                  child: Text(
                    prediction.description ?? '',
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        isCrossBtnShown: true,
      ),
    );
  }

  Widget nextButton() {
    return InkWell(
      onTap: placeController.text.isNotEmpty
          ? () {
              Navigator.pushNamed(context, '/onboardingHoroscopesQuestion');
            }
          : null,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.5,
        ),
        decoration: BoxDecoration(
          color: placeController.text.isNotEmpty 
              ? primaryColor 
              : const Color(0xFF3D3761),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: placeController.text.isNotEmpty
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          'NEXT',
          style: TextStyle(
            color: placeController.text.isNotEmpty ? whiteColor : greyColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

