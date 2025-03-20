import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lipht/data/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserModel?> getCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson({'id': doc.id, ...doc.data()!});
      }
    }
    return null;
  }

  // Create user with email and password
  Future<UserModel?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? photoUrl,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      userCredential.user!.updateDisplayName('$firstName $lastName');
      userCredential.user!.updatePhotoURL(photoUrl);

      await createNewUser(
        userCredential.user!.uid,
        email,
        firstName,
        lastName,
        photoUrl,
      );
      return getCurrentUser();
    } catch (e) {
      //print('Error creating user: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return verifyUserCredential(userCredential);
    } catch (e) {
      //print(e.toString());
      rethrow; // Re-throw the error so it can be caught by the provider
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle(GoogleSignIn googleSignIn) async {
    try {
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      return verifyUserCredential(userCredential);
    } catch (e) {
      //print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<UserModel?> verifyUserCredential(UserCredential userCredential) async {
    try {
      // Update user profile using userCredential
      if (userCredential.user != null) {
        await updateUser(userCredential);
        return getCurrentUser();
      }
      return null;
    } catch (e) {
      //print('Error signing in with Credentials: $e');
      return null;
    }
  }

  Future<bool> updateUser(UserCredential userCredential) async {
    try {
      final userId = userCredential.user!.uid;

      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();

      // Update last login
      if (userDoc.exists) {
        // Update last login
        await updateLastLoginTime(userId);
      } else {
        // Create new user if doesn't exist
        await createNewUser(
            userCredential.user!.uid,
            userCredential.user!.email!,
            userCredential.user!.displayName!.split(' ')[0],
            userCredential.user!.displayName!.split(' ')[1],
            userCredential.user!.photoURL);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateLastLoginTime(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      //print("Failure updating last login time");
      return false;
    }
  }

  Future<bool> createNewUser(String userId, String email, String firstName,
      String lastName, String? photoUrl) async {
    try {
      final newUser = UserModel.createDefault(
        userId: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl,
      );

      await _firestore.collection('users').doc(userId).set(newUser.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Listen for authentication state changes
  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) {
        return null;
      }
      return await getCurrentUser();
    });
  }
}
