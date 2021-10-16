import 'package:dbcrypt/dbcrypt.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';
import '../enums/role_enum.dart';
import '../models/result_model.dart';
import '../models/user_model.dart';
import '../services/user_services.dart';

class Setup {
  static Setup get instance => Setup();

  Future<void> init() async {
    Result<List<User>> result = await UserService.instance.getUser('type', Role.ADMIN.accessLevel);

    if(result.hasError) {
      User user = User(
        id: Uuid().v4(),
        email: DEFAULT_ADMIN_EMAIL,
        password: DBCrypt().hashpw(DEFAULT_ADMIN_PASSWORD, DBCrypt().gensalt()),
        firstName: DEFAULT_ADMIN_FIRST_NAME,
        lastName: DEFAULT_ADMIN_LAST_NAME,
        schoolAddress: "",
        schoolName: "",
        schoolType: "",
        childAge: "",
        childName: "",
        type: Role.ADMIN.accessLevel,
        photo: "",
        gender: "Male",
      );

      await UserService.instance.setUser(user);
    }
  }
}