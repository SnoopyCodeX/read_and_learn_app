import '../constants.dart';
import '../models/certificate_holder_model.dart';
import '../models/result_model.dart';
import 'firestore_services.dart';

class CertificateHolderService {
  FirestoreService _firestoreService = FirestoreService.instance;

  static CertificateHolderService get instance => CertificateHolderService();

  Future<Result<List<CertificateHolder>>> getAllCertificateHolders() async {
    List<Map<String, dynamic>> result =
        await _firestoreService.getData(CERTIFICATE_HOLDERS_TABLE);

    if (result.isEmpty) {
      return Result<List<CertificateHolder>>(
        message: 'No certificate holders found',
        hasError: true,
      );
    }

    return Result<List<CertificateHolder>>(
      data: result.map((json) => CertificateHolder.fromJson(json)).toList(),
    );
  }

  Future<Result<CertificateHolder?>> getCertificateHolder(
      String classroomId, String userId) async {
    List<Map<String, dynamic>> result = await _firestoreService.findData(
      CERTIFICATE_HOLDERS_TABLE,
      key: 'classroom_id',
      isEqualTo: classroomId,
    );

    if (result.isEmpty)
      return Result<CertificateHolder?>(
        message: 'No certificate holder found',
        hasError: true,
      );

    CertificateHolder? holder;
    bool found = false;
    for (Map<String, dynamic> json in result)
      if (json['user_id'] == userId) {
        holder = CertificateHolder.fromJson(json);
        found = true;
        break;
      }

    return Result<CertificateHolder?>(
      message: found ? '' : 'No certificate holder found',
      data: holder,
      hasError: !found,
    );
  }

  Future<Result<void>> addNewCertificateHolder(CertificateHolder holder) async {
    await _firestoreService.setData(
      CERTIFICATE_HOLDERS_TABLE,
      holder.id,
      holder.toJson(),
    );

    return Result();
  }

  Future<Result<void>> deleteCertificateHolder(
      String classroomId, String userId) async {
    List<Map<String, dynamic>> result = await _firestoreService.findData(
      CERTIFICATE_HOLDERS_TABLE,
      key: 'classroom_id',
      isEqualTo: classroomId,
    );

    if (result.isEmpty)
      return Result(
        hasError: true,
        message: 'Certificate holder is does not exist',
      );

    for (Map<String, dynamic> json in result)
      if (json['user_id'] == userId) {
        await _firestoreService.deleteData(
          CERTIFICATE_HOLDERS_TABLE,
          json['id'],
        );

        break;
      }

    return Result();
  }
}
