import 'dart:io';

import '../constants.dart';
import '../models/result_model.dart';
import '../models/user_model.dart';
import 'firestore_services.dart';

class UserService {

  FirestoreService _firestoreService = FirestoreService.instance;

  static UserService get instance {
    return UserService();
  }

  Future<Result<List<User>>> getAllUsers() async {
    List<Map<String, dynamic>> data = await _firestoreService.getData(USERS_TABLE);
    
    if(data.length > 0)
    {
      List<User> users = data.map(
        (json) => User.fromJson(json)
      ).toList();

      return Result<List<User>>(
        data: users
      );
    }
    else 
      return Result<List<User>>(
        hasError: true,
        message: MESSAGES['users']!['no_users']!
      );
  }

  Future<Result<List<User>>> getUser(String key, dynamic value) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      USERS_TABLE, 
      key: key, 
      isEqualTo: value
    );

    if(data.length > 0)
    {
      List<User> users = data.map(
        (json) => User.fromJson(json)
      ).toList();

      return Result<List<User>>(
        data: users
      );
    }
    else 
      return Result<List<User>>(
        hasError: true,
        message: MESSAGES['users']!['no_users']!
      );
  }

  Future<Result> setUser(User user) async {
    await _firestoreService.setData(
      USERS_TABLE, 
      user.id, 
      user.toJson()
    );

    return Result();
  }

  Future<Result> deleteUser(User user) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      USERS_TABLE,
      key: 'id',
      isEqualTo: user.id
    );

    if(data.length > 0) 
    {
      await _firestoreService.setData(
        USERS_TABLE, 
        user.id, 
        {'is_deleted': true}
      );

      return Result();
    }
    else 
      return Result(
        message: MESSAGES['users']!['no_user']!,
        hasError: true
      );
  }

  Future<Result> recoverUser(User user) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      USERS_TABLE,
      key: 'id',
      isEqualTo: user.id
    );

    if(data.length > 0) 
    {
      await _firestoreService.setData(
        USERS_TABLE, 
        user.id, 
        {'is_deleted': false}
      );

      return Result();
    }
    else 
      return Result(
        message: MESSAGES['users']!['no_user']!,
        hasError: true
      );
  }

  Future<Result<String>> uploadPhoto(String id, File file) async {
    String photoUrl = await _firestoreService.uploadFile(file, '$PHOTOS_FOLDER/$id');

    return Result<String>(
      message: MESSAGES['users']!['photo_upload_success']!,
      data: photoUrl
    );
  }

  Future<Result> deletePhoto(String id) async {
    await _firestoreService.deleteFile('$PHOTOS_FOLDER/$id');

    return Result(
      message: MESSAGES['users']!['photo_delete_success']!
    );
  }

  Future<Result<String>> uploadAudio(String id, File file) async {
    String audioUrl = await _firestoreService.uploadFile(file, '$AUDIOS_FOLDER/$id');

    return Result<String>(
      message: MESSAGES['users']!['audio_upload_success']!,
      data: audioUrl
    );
  }

  Future<Result> deleteAudio(String id) async {
    await _firestoreService.deleteFile('$AUDIOS_FOLDER/$id');

    return Result(
      message: MESSAGES['users']!['audio_delete_failed']!
    );
  } 
}