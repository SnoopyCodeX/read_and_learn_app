import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  static FirestoreService get instance {
    return FirestoreService();
  }

  Future<String> uploadFile(File file, String id) async {
    Reference ref = _storage.ref().child('');
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => print("Upload: DONE!"));
    return await snapshot.ref.getDownloadURL();
  }
}