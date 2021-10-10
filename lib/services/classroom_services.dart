import '../constants.dart';
import '../models/class_member_model.dart';
import '../models/classroom_model.dart';
import '../models/result_model.dart';
import 'classroom_member_services.dart';
import 'firestore_services.dart';
import 'story_services.dart';

class ClassroomService {
  
  FirestoreService _firestoreService = FirestoreService.instance;

  static ClassroomService get instance {
    return ClassroomService();
  }

  Future<Result<List<Classroom>>> getAllClassrooms() async {
    List<Map<String, dynamic>> data = await _firestoreService.getData(CLASSROOMS_TABLE);

    return Result<List<Classroom>>(
      data: data.length > 0
        ? data.map((json) => Classroom.fromJson(json)).toList()
        : null,
      message: MESSAGES['classroom']!['no_classrooms_found']!,
      hasError: data.length <= 0
    );
  }
  
  Future<Result<List<Classroom>>> getAllActiveClassrooms() async {
    List<Map<String, dynamic>> data = await _firestoreService.getData(CLASSROOMS_TABLE);

    // Filter out deleted classrooms
    List<Map<String, dynamic>> filteredData = [];
    for(Map<String, dynamic> json in data)
      if(!json['is_deleted'])
        filteredData.add(json);

    return Result<List<Classroom>>(
      data: filteredData.length > 0
        ? filteredData.map((json) => Classroom.fromJson(json)).toList()
        : null,
      message: MESSAGES['classroom']!['no_classrooms_found']!,
      hasError: filteredData.length <= 0
    );
  }

  Future<Result<List<Classroom>>> getClassroom(String key, dynamic value) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      CLASSROOMS_TABLE, 
      key: key,
      isEqualTo: value
    );

    return Result<List<Classroom>>(
      data: data.length > 0 
        ? data.map((json) => Classroom.fromJson(json)).toList()
        : null,
      message: MESSAGES['classroom']!['no_classrooms_found']!,
      hasError: data.length <= 0
    );
  }

  Future<Result<List<Classroom>>> getActiveClassroom(String key, dynamic value) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      CLASSROOMS_TABLE, 
      key: key,
      isEqualTo: value
    );

    // Filter out deleted classrooms
    List<Map<String, dynamic>> filteredData = [];
    for(Map<String, dynamic> json in data)
      if(!json['is_deleted'])
        filteredData.add(json);

    return Result<List<Classroom>>(
      data: filteredData.length > 0 
        ? filteredData.map((json) => Classroom.fromJson(json)).toList()
        : null,
      message: MESSAGES['classroom']!['no_classrooms_found']!,
      hasError: filteredData.length <= 0
    );
  }

  Future<Result<List<Classroom>>> getJoinedClassroom(String userId) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      CLASS_MEMBERS_TABLE, 
      key: 'member_id',
      isEqualTo: userId,
    );

    if(data.isNotEmpty) {
      List<ClassMember> members = data.map((json) => ClassMember.fromJson(json)).toList();
      List<Classroom> classes = [];

      for(ClassMember member in members)
        if(!member.isPending)
          classes.add((await getClassroom('id', member.classId)).data![0]);

      return Result<List<Classroom>>(
        data: classes,
        hasError: classes.isEmpty,
      );
    }

    return Result<List<Classroom>>(
      hasError: true,
      message: 'No classes joined',
    );
  }

  Future<void> leaveClassroom(String userId, String classId) async {
    await ClassMemberService.instance.denyOrRemoveMember(classId, userId, leaveRoom: true);
  }

  Future<Result<void>> setClassroom(Classroom classroom) async {
    await _firestoreService.setData(
      CLASSROOMS_TABLE, 
      classroom.id, 
      classroom.toJson()
    );

    return Result<void>(
      message: MESSAGES['classroom']!['classroom_create_or_update_successful']!
    );
  }

  Future<Result<void>> deleteClassroom(String id) async {
    await StoryService.instance.deleteAllStoriesFromClass(id);

    await _firestoreService.deleteData(
      CLASSROOMS_TABLE,
      id
    );

    return Result<void>(
      message: MESSAGES['classroom']!['classroom_delete_successful']!
    );
  }
}