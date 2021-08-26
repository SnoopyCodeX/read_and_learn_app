class Classroom {
  final String id;
  final String name;
  final String section;
  final String code;
  final String teacher;
  final bool isDeleted;

  const Classroom({
    required this.id,
    required this.name,
    required this.section,
    required this.code,
    required this.teacher,
    this.isDeleted = false
  });

  static Classroom fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'], 
      name: json['name'], 
      section: json['section'],
      code: json['code'], 
      teacher: json['teacher'],
      isDeleted: json['is_deleted']
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': this.id,
      'name': this.name,
      'section': this.section,
      'code': this.code,
      'teacher': this.teacher,
      'is_deleted': this.isDeleted
    };
  }
}