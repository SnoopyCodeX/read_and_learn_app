class CertificateHolder {
  final String id;
  final String userId;
  final String teacherId;
  final String classroomId;
  final String userName;
  final String teacherName;
  final String classroomName;
  final String dateAcquired;
  final String age;

  const CertificateHolder({
    required this.id,
    required this.userId,
    required this.teacherId,
    required this.classroomId,
    required this.userName,
    required this.teacherName,
    required this.classroomName,
    required this.dateAcquired,
    required this.age,
  });

  static CertificateHolder fromJson(Map<String, dynamic> json) {
    return CertificateHolder(
      id: json['id'],
      userId: json['user_id'],
      teacherId: json['teacher_id'],
      classroomId: json['classroom_id'],
      userName: json['user_name'],
      teacherName: json['teacher_name'],
      classroomName: json['classroom_name'],
      dateAcquired: json['date_acquired'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': this.id,
      'user_id': this.userId,
      'teacher_id': this.teacherId,
      'classroom_id': this.classroomId,
      'user_name': this.userName,
      'teacher_name': this.teacherName,
      'classroom_name': this.classroomName,
      'date_acquired': this.dateAcquired,
      'age': this.age,
    };
  }
}
