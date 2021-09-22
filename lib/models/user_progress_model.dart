class UserProgress {
  final String id;
  final String classId;
  final String userId;
  final String name;
  final String photoUrl;
  final String storyId;
  final String status;
  final String accuracy;
  final String speed;
  final String dateFinished;
  final String dateStarted;

  const UserProgress({
    required this.id,
    required this.classId,
    required this.userId,
    required this.name,
    required this.photoUrl,
    required this.storyId,
    required this.status,
    required this.accuracy,
    required this.speed,
    required this.dateFinished,
    required this.dateStarted
  });

  static UserProgress fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'],
      classId: json['class_id'],
      userId: json['user_id'],
      name: json['name'],
      photoUrl: json['photo_url'],
      storyId: json['story_id'],
      status: json['status'],
      accuracy: json['accuracy'],
      speed: json['speed'],
      dateFinished: json['date_finished'],
      dateStarted: json['date_started']
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': this.id,
      'class_id': this.classId,
      'user_id': this.userId,
      'name': this.name,
      'photo_url': this.photoUrl,
      'story_id': this.storyId,
      'status': this.status,
      'accuracy': this.accuracy,
      'speed': this.speed,
      'date_finished': this.dateFinished,
      'date_started': this.dateStarted
    };
  }
}