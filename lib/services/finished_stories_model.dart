import '../constants.dart';
import '../models/finished_stories_model.dart';
import '../models/result_model.dart';
import 'firestore_services.dart';

class FinishedStoriesServices {
  FirestoreService _firestoreService = FirestoreService.instance;

  static FinishedStoriesServices get instance => FinishedStoriesServices();

  Future<Result<List<FinishedStories>?>> getFinishedStories(
      String userId, String classId) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      FINISHED_STORIES_TABLE,
      key: 'classroom_id',
      isEqualTo: classId,
    );

    List<FinishedStories> finishedStories = [];
    if (data.length > 0) {
      for (Map<String, dynamic> json in data)
        if (json['user_id'] == userId)
          finishedStories.add(FinishedStories.fromJson(json));
    }

    return Result<List<FinishedStories>?>(
      data: finishedStories.isEmpty ? null : finishedStories,
      hasError: finishedStories.isEmpty,
      message: finishedStories.isEmpty ? 'No finished stories yet!' : '',
    );
  }
}
