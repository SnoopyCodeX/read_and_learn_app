class Story {
  final String id;
  final String title;
  final String content;
  final String thumbnail;
  final String classroom;
  final String classroomName;
  final String authorName;
  final String dateCreated;
  final bool isDeleted;

  const Story({
    required this.id,
    required this.title,
    required this.content,
    required this.thumbnail,
    required this.classroom,
    required this.classroomName,
    required this.authorName,
    required this.dateCreated,
    this.isDeleted = false,
  });

  static Story fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      thumbnail: json['thumbnail'],
      classroom: json['classroom'],
      classroomName: json['classroom_name'],
      authorName: json['author_name'],
      dateCreated: json['date_created'],
      isDeleted: json['is_deleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': this.id,
      'title': this.title,
      'content': this.content,
      'thumbnail': this.thumbnail,
      'classroom': this.classroom,
      'classroom_name': this.classroomName,
      'author_name': this.authorName,
      'date_created': this.dateCreated,
      'is_deleted': this.isDeleted,
    };
  }
}
