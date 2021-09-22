import 'package:uuid/uuid.dart';

import '../constants.dart';
import '../models/class_member_model.dart';
import '../models/result_model.dart';
import '../models/user_model.dart';
import 'firestore_services.dart';
import 'user_services.dart';

class ClassMemberService {

  FirestoreService _firestoreService = FirestoreService.instance;

  static ClassMemberService get instance {
    return ClassMemberService();
  }

  Future<Result<List<User>?>> getAllMembers(String classId, {bool pending = false}) async {
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      CLASS_MEMBERS_TABLE,
      key: 'class_id',
      isEqualTo: classId,
    );

    if(data.length > 0) 
    {
      List<String> memberIds = <String>[];
      List<ClassMember> members = data
        .map((json) => ClassMember.fromJson(json))
        .toList();

      members.forEach((member) {
        if(member.isPending == pending)
          memberIds.add(member.memberId);
      });

      Result<List<User>> resultUsers = await UserService.instance.getAllUsers();
      List<User> users = resultUsers.data as List<User>;
      List<User> temp = [];
      
      for(User user in users) 
        temp.add(user);
      
      for(User user in temp) {
        if(!memberIds.contains(user.id) || user.type == 1)
          users.remove(user);
      }

      return Result<List<User>?>(
        data: users,
        hasError: users.isEmpty,
      );
    }
    else
      return Result<List<User>?>(
        hasError: true,
        message: MESSAGES['classroom']!['no_members_found']!
      );
  }

  Future<int> countStudentsFromClass(String classId) async {
    Result<List<User>?> result = await getAllMembers(classId);
    
    return result.hasError 
      ? 0
      : result.data!.length;
  }

  Future<bool> acceptMember(String classId, String memberId) async {
    bool accepted = false;
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      CLASS_MEMBERS_TABLE,
      key: 'class_id',
      isEqualTo: classId
    );

    if(data.length > 0)
    {
      List<ClassMember> members = data
        .map((json) => ClassMember.fromJson(json))
        .toList();

      members.forEach((member) async {
        if(member.isPending && member.memberId == memberId) {
          await _firestoreService.setData(
            CLASS_MEMBERS_TABLE,
            member.id,
            {'is_pending': false}
          );

          accepted = true;
        }
      });
    }

    return accepted;
  }

  Future<bool> denyOrRemoveMember(String classId, String memberId) async {
    bool deleted = false;
    List<Map<String, dynamic>> data = await _firestoreService.findData(
      CLASS_MEMBERS_TABLE,
      key: 'class_id',
      isEqualTo: classId
    );

    if(data.length > 0)
    {
      List<ClassMember> members = data
        .map((json) => ClassMember.fromJson(json))
        .toList();

      for(ClassMember member in members) {
        if(member.isPending && member.memberId == memberId) {
          await _firestoreService.deleteData(
            CLASS_MEMBERS_TABLE,
            member.id,
          );

          deleted = true;
          break;
        }
      }
    }

    return deleted;
  }

  Future<bool> addNewPendingMember(String classId, User member) async {
    bool added = false, exists = false;
    Result<List<User>?> result = await getAllMembers(classId, pending: true);

    if(!result.hasError)
      for(User user in result.data!)
        if(user.id == member.id) {
          exists = true;
          break;
        }

    if(!exists) {
      ClassMember newMember = ClassMember(
        id: Uuid().v4(),
        classId: classId,
        memberId: member.id,
        isPending: true,
      );

      await _firestoreService.setData(
        CLASS_MEMBERS_TABLE, 
        newMember.id, 
        newMember.toJson(),
      );

      added = true;
    }

    return added;
  }
}