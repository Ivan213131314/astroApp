import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();
  
  TextEditingController nameController = TextEditingController();
  
  File? _selectedImage;
  String? _currentPhotoPath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final name = await _userService.getUserName();
    final photoPath = await _userService.getLocalProfilePhotoPath();
    
    if (name != null && name.isNotEmpty) {
      setState(() {
        nameController.text = name;
      });
    }
    
    if (photoPath != null) {
      setState(() {
        _currentPhotoPath = photoPath;
      });
    }
  }

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
                getTranslation(context, 'edit_profile.edit_profile'),
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
            top: fixPadding),
        children: [
          profileImage(size),
          heightSpace,
          heightSpace,
          heightSpace,
          nameField(),
          heightSpace,
          heightSpace,
          heightSpace,
          updateButton()
        ],
      ),
    );
  }

  updateButton() {
    return InkWell(
      onTap: () async {
        // Сохраняем фото если выбрано новое
        if (_selectedImage != null) {
          await _userService.saveLocalProfilePhoto(_selectedImage!);
        }
        
        // Сохраняем имя пользователя
        if (nameController.text.isNotEmpty) {
          await _userService.saveUserName(nameController.text);
        }
        if (!mounted) return;
        Navigator.pop(context);
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
          getTranslation(context, 'edit_profile.update'),
          style: bold20White,
        ),
      ),
    );
  }



  nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'edit_profile.user_name'),
          style: bold16WhiteF4,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: recBgColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextField(
            style: medium15WhiteF4,
            cursorColor: primaryColor,
            controller: nameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: fixPadding * 1.4,
                horizontal: fixPadding * 2.0,
              ),
              hintText: getTranslation(context, 'edit_profile.enter_name'),
              hintStyle: medium15Grey,
            ),
          ),
        )
      ],
    );
  }

  profileImage(Size size) {
    return Center(
      child: SizedBox(
        height: size.height * 0.152,
        width: size.height * 0.15,
        child: Stack(
          children: [
            Container(
              height: size.height * 0.15,
              width: size.height * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: _getProfileImage(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 2,
              child: InkWell(
                onTap: () {
                  changephotoBottomSheet();
                },
                child: Container(
                  height: size.height * 0.042,
                  width: size.height * 0.042,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: whiteF4Color,
                    boxShadow: [
                      BoxShadow(
                          color: recBgColor.withValues(alpha: 0.25),
                          blurRadius: 6)
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.camera_alt,
                    color: primaryColor,
                    size: 17,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  
  ImageProvider _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_currentPhotoPath != null) {
      return FileImage(File(_currentPhotoPath!));
    } else {
      return const AssetImage("assets/profile/profileImage.png");
    }
  }

  changephotoBottomSheet() {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(fixPadding * 2.0),
          width: double.maxFinite,
          decoration: const BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(fixPadding),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslation(context, 'edit_profile.change_profile_Photo'),
                style: bold18BlueShade1,
              ),
              heightSpace,
              heightSpace,
              imageOptionWidget(Icons.camera_alt, const Color(0xFF1E4799),
                  getTranslation(context, 'edit_profile.camera'), _pickImageFromCamera),
              heightSpace,
              heightSpace,
              imageOptionWidget(Icons.photo, const Color(0xFF1E996D),
                  getTranslation(context, 'edit_profile.gallery'), _pickImageFromGallery),
              heightSpace,
              heightSpace,
              imageOptionWidget(Icons.delete, const Color(0xFFEF1717),
                  getTranslation(context, 'edit_profile.remove_image'), _removePhoto),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    Navigator.pop(context);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image from camera: $e');
    }
  }
  
  Future<void> _pickImageFromGallery() async {
    Navigator.pop(context);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
  }
  
  Future<void> _removePhoto() async {
    Navigator.pop(context);
    setState(() {
      _selectedImage = null;
      _currentPhotoPath = null;
    });
    
    await _userService.deleteLocalProfilePhoto();
  }

  imageOptionWidget(IconData icon, Color color, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: black03Color.withValues(alpha: 0.2),
                  blurRadius: 6,
                )
              ],
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          widthSpace,
          widthSpace,
          Expanded(
            child: Text(
              title,
              style: medium16Blue,
            ),
          )
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
