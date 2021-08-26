class Story {
  final String id;
  final String title;
  final String content;
  final String thumbnail;
  final String classroom;
  final bool isDeleted;

  const Story({
    required this.id,
    required this.title,
    required this.content,
    required this.thumbnail,
    required this.classroom,
    this.isDeleted = false
  });

  static Story fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      thumbnail: json['thumbnail'],
      classroom: json['classroom'],
      isDeleted: json['is_deleted']
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': this.id,
      'title': this.title,
      'content': this.content,
      'thumbnail': this.thumbnail,
      'classroom': this.classroom,
      'is_deleted': this.isDeleted
    };
  }
}