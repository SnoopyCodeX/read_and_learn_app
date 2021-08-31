import 'dart:io';

import '../constants.dart';
import '../models/result_model.dart';
import '../models/story_model.dart';
import 'firestore_services.dart';

class StoryService {

  FirestoreService _firestoreService = FirestoreService.instance;

  static StoryService get instance {
    return StoryService();
  }

  Future<Result<List<Story>>> getAllStories() async {
    List<Map<String, dynamic>> data = await _firestoreService.getData(STORIES_TABLE);

    return Result<List<Story>>(
      data: data.length > 0 
        ? data.map((json) => Story.fromJson(json)).toList()
        : null,
      message: MESSAGES['story']!['stories_not_found']!,
      hasError: data.length <= 0
    );
  }

  Future<Result<List<Story>>> getStory(String key, dynamic value) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      STORIES_TABLE, 
      key: key,
      isEqualTo: value
    );

    return Result<List<Story>>(
      data: data.length > 0
        ? data.map((json) => Story.fromJson(json)).toList()
        : null,
      message: MESSAGES['story']!['no_stories_found']!,
      hasError: data.length <= 0
    );
  }

  Future<Result<void>> setStory(Story story) async {
    await _firestoreService.setData(
      STORIES_TABLE, 
      story.id, 
      story.toJson()
    );

    return Result<void>(
      message: MESSAGES['story']!['story_create_or_update_success']!
    );
  }

  Future<Result<void>> deleteStory(String id) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      STORIES_TABLE, 
      key: 'id',
      isEqualTo: id
    );

    if(data.length > 0)
      await _firestoreService.setData(
        STORIES_TABLE, 
        id,
        {'is_deleted': true}
      );

    return Result<void>(
      message: data.length > 0 
        ? MESSAGES['story']!['story_delete_success']!
        : MESSAGES['story']!['stories_not_found']!,
      hasError: data.length <= 0
    );
  }

  Future<Result<String>> uploadThumbnail(String id, File file) async {
    String thumbnailUrl = await _firestoreService.uploadFile(file, '$PHOTOS_FOLDER/$id');

    return Result<String>(
      message: MESSAGES['story']!['story_upload_thumbnail_success']!,
      data: thumbnailUrl
    );
  }

  Future<Result<void>> deleteThumbnail(String id) async {
    await _firestoreService.deleteFile('$PHOTOS_FOLDER/$id');

    return Result<void>(
      message: MESSAGES['story']!['story_delete_thumbnail_success']!
    );
  }
}