enum Role {
  ADMIN,
  TEACHER,
  PARENT,
}

extension RoleExtension on Role {
  int get accessLevel => [2, 1, 0][this.index];
}