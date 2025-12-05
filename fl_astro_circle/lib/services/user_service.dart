import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Получить ссылку на документ пользователя
  DocumentReference? get _userDoc {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId);
  }

  /// Сохранить имя пользователя в Firestore и кэш
  Future<void> saveUserName(String name) async {
    if (name.isEmpty) return;
    
    // Сохраняем в кэш (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    
    // Сохраняем в Firestore, если пользователь авторизован
    if (_userDoc != null) {
      await _userDoc!.set({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  /// Получить имя пользователя (сначала из кэша, потом из Firestore)
  Future<String?> getUserName() async {
    // Сначала пробуем получить из кэша
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('user_name');
    
    // Если в кэше нет, пробуем из Firestore
    if ((name == null || name.isEmpty) && _userDoc != null) {
      try {
        final doc = await _userDoc!.get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          name = data?['name'] as String?;
          
          // Сохраняем в кэш для быстрого доступа в будущем
          if (name != null && name.isNotEmpty) {
            await prefs.setString('user_name', name);
          }
        }
      } catch (e) {
        print('Error loading user name from Firestore: $e');
      }
    }
    
    return name;
  }

  /// Обновить профиль пользователя (дополнительные поля)
  Future<void> updateUserProfile({
    String? email,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
  }) async {
    if (_userDoc == null) return;
    
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (email != null) updates['email'] = email;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (dateOfBirth != null) updates['dateOfBirth'] = dateOfBirth;
    if (gender != null) updates['gender'] = gender;
    
    await _userDoc!.set(updates, SetOptions(merge: true));
  }

  /// Получить профиль пользователя
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_userDoc == null) return null;
    
    try {
      final doc = await _userDoc!.get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
    
    return null;
  }

  /// Stream для получения профиля пользователя в реальном времени
  Stream<Map<String, dynamic>?> getUserProfileStream() {
    if (_userDoc == null) return Stream.value(null);
    
    return _userDoc!.snapshots().map((doc) {
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    });
  }

  /// Сохранить локальное фото профиля (с привязкой к userId)
  Future<String?> saveLocalProfilePhoto(File imageFile) async {
    if (_userId == null) return null;
    
    try {
      // Получаем директорию для постоянного хранения
      final directory = await getApplicationDocumentsDirectory();
      final photoDir = Directory('${directory.path}/profile_photos');
      
      // Создаем папку если не существует
      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }
      
      // Копируем файл с именем userId
      final fileName = '$_userId.jpg';
      final savedImage = File('${photoDir.path}/$fileName');
      await imageFile.copy(savedImage.path);
      
      // Сохраняем путь в SharedPreferences с ключом userId
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('photo_path_$_userId', savedImage.path);
      
      return savedImage.path;
    } catch (e) {
      print('Error saving local profile photo: $e');
      return null;
    }
  }
  
  /// Получить путь к локальному фото для текущего пользователя
  Future<String?> getLocalProfilePhotoPath() async {
    if (_userId == null) return null;
    
    final prefs = await SharedPreferences.getInstance();
    final photoPath = prefs.getString('photo_path_$_userId');
    
    // Проверяем, существует ли файл
    if (photoPath != null) {
      final file = File(photoPath);
      if (await file.exists()) {
        return photoPath;
      } else {
        // Файл был удален, очищаем кэш
        await prefs.remove('photo_path_$_userId');
      }
    }
    
    return null;
  }
  
  /// Удалить локальное фото профиля
  Future<void> deleteLocalProfilePhoto() async {
    if (_userId == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final photoPath = prefs.getString('photo_path_$_userId');
      
      if (photoPath != null) {
        final file = File(photoPath);
        if (await file.exists()) {
          await file.delete();
        }
        await prefs.remove('photo_path_$_userId');
      }
    } catch (e) {
      print('Error deleting local profile photo: $e');
    }
  }

  /// Очистить данные пользователя при выходе
  /// НЕ удаляем фото - оно должно сохраниться для этого userId
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    // photo_path_$userId НЕ удаляем - оно привязано к конкретному пользователю
  }
}
