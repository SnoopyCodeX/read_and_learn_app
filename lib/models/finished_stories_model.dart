class FinishedStories {
  final String id;
  final String storyId;
  final String userId;
  final String classroomId;
  final String dateFinished;

  const FinishedStories({
    required this.id,
    required this.storyId,
    required this.userId,
    required this.classroomId,
    required this.dateFinished,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": this.id,
      "story_id": this.storyId,
      "user_id": this.userId,
      "classroom_id": this.classroomId,
      "date_finished": this.dateFinished,
    };
  }

  static FinishedStories fromJson(Map<String, dynamic> json) {
    return FinishedStories(
      id: json['id'],
      storyId: json['story_id'],
      userId: json['user_id'],
      classroomId: json['classroom_id'],
      dateFinished: json['date_finished'],
    );
  }
}
