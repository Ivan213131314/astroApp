import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final recentSeachList = [
    "Aries horoscope",
    "Astrologers",
    "Virgo horoscope",
    "Natal chart",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                  getTranslation(context, 'search.search'),
                  style: bold18White,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            searchField(),
            recentSeachList.isEmpty ? const SizedBox() : recentTitle(),
            heightSpace,
            recentSearchListContent(),
          ],
        ),
      ),
    );
  }

  recentSearchListContent() {
    return Expanded(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: recentSeachList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: fixPadding * 2.0, vertical: fixPadding / 2),
            child: Row(
              children: [
                const Text(
                  "#",
                  style: medium16Grey,
                ),
                widthSpace,
                Expanded(
                  child: Text(
                    recentSeachList[index].toString(),
                    style: medium15Grey,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  recentTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              getTranslation(context, 'search.recent_search'),
              style: medium16WhiteF4,
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                recentSeachList.clear();
              });
            },
            child: Text(
              getTranslation(context, 'search.clear_all'),
              style: medium14WhiteF4,
            ),
          )
        ],
      ),
    );
  }

  searchField() {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(
          horizontal: fixPadding * 2.0, vertical: fixPadding),
      width: double.maxFinite,
      decoration: BoxDecoration(
          color: blueShade1, borderRadius: BorderRadius.circular(5.0)),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: fixPadding * 2.0,
            vertical: fixPadding,
          ),
          hintText: getTranslation(context, 'search.search'),
          prefixIcon: const Icon(
            Icons.search,
            size: 22,
          ),
          hintStyle: medium16Grey,
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
