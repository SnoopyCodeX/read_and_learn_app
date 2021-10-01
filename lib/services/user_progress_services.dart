import '../constants.dart';
import '../models/result_model.dart';
import '../models/user_progress_model.dart';
import 'firestore_services.dart';

class UserProgressService {

  FirestoreService _firestoreService = FirestoreService.instance;

  static UserProgressService get instance {
    return UserProgressService();
  }

  Future<Result> resetAllUserProgress(String userId, String classId) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      USER_PROGRESS_TABLE, 
      key: 'class_id',
      isEqualTo: classId,
    );

    if(data.isNotEmpty)
      for(Map<String, dynamic> json in data)
      {
        UserProgress progress = UserProgress.fromJson(json);

        if(progress.userId == userId)
          await _firestoreService.deleteData(
            USER_PROGRESS_TABLE, 
            progress.id,
          );
      }

    return Result(
      message: data.isNotEmpty 
        ? 'Your progress has been successfully reset' 
        : 'You do not have progresses to reset',
      hasError: data.isEmpty,
    );
  }

  Future<Result> resetUserProgress(String userId, String classId, String storyId) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      USER_PROGRESS_TABLE, 
      key: 'class_id',
      isEqualTo: classId,
    );

    if(data.isNotEmpty)
      for(Map<String, dynamic> json in data)
      {
        UserProgress progress = UserProgress.fromJson(json);

        if(progress.userId == userId && progress.storyId == storyId){
          await _firestoreService.deleteData(
            USER_PROGRESS_TABLE, 
            progress.id,
          );

          break;
        }
      }

    return Result(
      message: data.isNotEmpty 
        ? 'Your progress has been successfully reset' 
        : 'You do not have progresses to reset',
      hasError: data.isEmpty,
    );
  }

  Future<Result<List<UserProgress>?>> getUserProgress(String userId, String classId) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      USER_PROGRESS_TABLE, 
      key: 'class_id',
      isEqualTo: classId,
    );

    List<UserProgress> userProgress = [];
    if(data.isNotEmpty)
      for(Map<String, dynamic> json in data)
        if(json['user_id'] == userId)
          userProgress.add(UserProgress.fromJson(json));

    return Result<List<UserProgress>?>(
      data: userProgress.isEmpty ? null : userProgress,
      hasError: userProgress.isEmpty,
    );
  }
  
  Future<void> setUserProgress(UserProgress progress) async {
    await _firestoreService.setData(
      USER_PROGRESS_TABLE, 
      progress.id, 
      progress.toJson(),
    );
  }

  Future<Result<List<UserProgress>?>> getAllFinishedProgress(String classId, String userId) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      USER_PROGRESS_TABLE, 
      key: 'class_id',
      isEqualTo: classId,
    );

    List<UserProgress> userProgress = [];
    if(data.isNotEmpty) 
      for(Map<String, dynamic> json in data)
      {
        UserProgress progress = UserProgress.fromJson(json);

        if(progress.userId == userId && progress.status == STATUS_FINISHED_READING)
          userProgress.add(progress);
      }
    
    return Result<List<UserProgress>?>(
      data: userProgress.isNotEmpty ? userProgress : null,
      hasError: userProgress.isEmpty,
    );
  }

  Future<Result<List<UserProgress>?>> getAllNotFinishedProgress(String classId, String userId) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      USER_PROGRESS_TABLE, 
      key: 'class_id',
      isEqualTo: classId,
    );

    List<UserProgress> userProgress = [];
    if(data.isNotEmpty) 
      for(Map<String, dynamic> json in data)
      {
        UserProgress progress = UserProgress.fromJson(json);

        if(progress.userId == userId && progress.status == STATUS_STILL_READING)
          userProgress.add(progress);
      }
    
    return Result<List<UserProgress>?>(
      data: userProgress.isNotEmpty ? userProgress : null,
      hasError: userProgress.isEmpty,
    );
  }

  Future<Result<List<UserProgress>?>> getAllFinished(String classId, String storyId) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      USER_PROGRESS_TABLE, 
      key: 'class_id',
      isEqualTo: classId,
      orderBy: 'date_finished',
      orderDescending: true,
    );

    List<UserProgress> userProgress = [];
    if(data.isNotEmpty)
      for(Map<String, dynamic> json in data)
      {
        UserProgress progress = UserProgress.fromJson(json);

        if(progress.storyId == storyId && progress.status == STATUS_FINISHED_READING)
          userProgress.add(progress);
      }

    return Result<List<UserProgress>?>(
      data: userProgress.isNotEmpty ? userProgress : null,
      hasError: userProgress.isEmpty,
    );
  }

  Future<Result<List<UserProgress>?>> getAllNotFinished(String classId, String storyId) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      USER_PROGRESS_TABLE, 
      key: 'class_id',
      isEqualTo: classId,
      orderBy: 'date_started',
      orderDescending: true,
    );

    List<UserProgress> userProgress = [];
    if(data.isNotEmpty)
      for(Map<String, dynamic> json in data)
      {
        UserProgress progress = UserProgress.fromJson(json);

        if(progress.storyId == storyId && progress.status == STATUS_STILL_READING)
          userProgress.add(progress);
      }

    return Result<List<UserProgress>?>(
      data: userProgress.isNotEmpty ? userProgress : null,
      hasError: userProgress.isEmpty,
    );
  }

  Future<Result<List<UserProgress>?>> getProgress(String key, dynamic value) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      USER_PROGRESS_TABLE, 
      key: key,
      isEqualTo: value,
      orderBy: "accuracy",
      orderDescending: true,
    );

    return Result<List<UserProgress>?>(
      data: data.isNotEmpty
        ? data.map((json) => UserProgress.fromJson(json))
          .toList()
        : null,
      hasError: data.isEmpty
    );
  }
}