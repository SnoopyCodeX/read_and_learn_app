class User {
  final String id;
  final String firstName;
  final String lastName;
  final String gender;
  final String photo;
  final String email;
  final String password;
  final String schoolName;
  final String schoolAddress;
  final String schoolType;
  final String childName;
  final int childAge;
  final int type;
  final bool isDeleted;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.email,
    required this.password,
    this.schoolAddress = '',
    this.schoolName = '',
    this.schoolType = '',
    this.childAge = 0,
    this.childName = '',
    required this.photo,
    this.type = 0,
    this.isDeleted = false
  });

  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      gender: json['gender'],
      email: json['email'],
      password: json['password'],
      schoolName: json['school_name'],
      schoolAddress: json['school_address'],
      schoolType: json['school_type'],
      childAge: json['child_age'],
      childName: json['child_name'],
      photo: json['photo'],
      type: json['type'],
      isDeleted: json['is_deleted']
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': this.id,
      'first_name': this.firstName,
      'last_name': this.lastName,
      'gender': this.gender,
      'email': this.email,
      'password': this.password,
      'school_name': this.schoolName,
      'school_address': this.schoolAddress,
      'school_type': this.schoolType,
      'child_age': this.childAge,
      'child_name': this.childName,
      'photo': this.photo,
      'type': this.type,
      'is_deleted': this.isDeleted
    };
  }
}