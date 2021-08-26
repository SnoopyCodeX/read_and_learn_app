class ClassMember {
  final String id;
  final String memberId;
  final String classId;
  final bool isPending;

  const ClassMember({
    required this.id,
    required this.memberId,
    required this.classId,
    required this.isPending
  });

  static ClassMember fromJson(Map<String, dynamic> json) {
    return ClassMember(
      id: json['id'],
      memberId: json['member_id'],
      classId: json['class_id'],
      isPending: json['is_pending']
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': this.id,
      'member_id': this.memberId,
      'class_id': this.classId,
      'is_pending': this.isPending
    };
  }
}