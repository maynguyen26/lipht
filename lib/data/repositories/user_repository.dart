import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Method to update specific user settings/data
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    print(
        "USER_REPO: Updating user $userId with data: $data"); // Log the update
    try {
      await _firestore.collection('users').doc(userId).update(data);
      print("USER_REPO: User $userId update successful.");
    } catch (e) {
      print("USER_REPO: Error updating user data for $userId: $e");
      // Rethrow the error so the calling layer (Provider) can handle it
      rethrow;
    }
  }
}
