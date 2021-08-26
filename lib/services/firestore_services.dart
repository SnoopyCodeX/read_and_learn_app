import 'dart:io';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:read_and_learn/constants.dart';

class FirestoreService {

  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static FirebaseStorage _storage = FirebaseStorage.instance;

  static FirestoreService get instance {
    if(!kIsProduction) {
      _firestore.useFirestoreEmulator('localhost', 5777);
      _storage.useStorageEmulator('localhost', 9199);
    }

    return FirestoreService();
  }

  Future<String> uploadFile(File file, String path) async {
    Reference ref = _storage.ref().child(path);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => print("Upload: DONE!"));
    
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteFile(String path) async {
    return (_storage.ref().child(path).delete());
  }

  Future<List<Map<String, dynamic>>> getData(String collection) async {
    return (_firestore.collection(collection)
      .get()
      .then((snapshot) => snapshot.docs.map((doc) => doc.data())
      .toList()));
  }

  Future<void> setData(String collection, String doc, Map<String, dynamic> data) async {
    return (_firestore.collection(collection)
      .doc(doc)
      .set(data, SetOptions(merge: true)));
  }

  Future<List<Map<String, dynamic>>> findData(String collection, {
      required String key, 
      Object? isEqualTo,
      Object? isNotEqualTo,
      Object? isLessThan,
      Object? isLessThanOrEqualTo,
      Object? isGreaterThan,
      Object? isGreaterThanOrEqualTo,
      Object? arrayContains,
      List<Object?>? arrayContainsAny,
      List<Object?>? whereIn,
      List<Object?>? whereNotIn,
      bool? isNull
    }) async {

    return (_firestore.collection(collection)
      .where(key, 
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayContainsAny: arrayContainsAny,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
        isNull: isNull))
      .get()
      .then((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> deleteData(String collection, String doc) async {
    return (_firestore.collection(collection)
      .doc(doc)
      .delete());
  }
}