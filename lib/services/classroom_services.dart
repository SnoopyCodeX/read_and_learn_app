import '../constants.dart';
import '../models/classroom_model.dart';
import '../models/result_model.dart';
import 'firestore_services.dart';

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

  Future<Result<void>> setClassroom(Classroom classroom) async {
    await _firestoreService.setData(
      CLASSROOMS_TABLE, 
      classroom.id, 
      classroom.toJson()
    );

    return Result<void>(
      message: MESSAGES['classroom']!['classroom_create_or_update_success']!
    );
  }

  Future<Result<void>> deleteClassroom(String id) async {
    await _firestoreService.setData(
      CLASSROOMS_TABLE,
      id,
      {'is_deleted': true} 
    );

    return Result<void>(
      message: MESSAGES['classroom']!['classroom_delete_successful']!
    );
  }
}