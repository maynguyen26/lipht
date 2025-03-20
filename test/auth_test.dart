import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:lipht/data/models/user_model.dart';
import 'package:lipht/core/services/auth_service.dart';

void main() {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late MockGoogleSignIn googleSignIn;
  late AuthService authService;
  
  const testEmail = 'test@example.com';
  const testPassword = 'Test123!';
  const testFirstName = 'Test';
  const testLastName = 'User';
  const testUid = 'test-uid';

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Initialize mocks
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    authService = AuthService(auth: auth, firestore: firestore);
    googleSignIn = MockGoogleSignIn();
  });

  group('Authentication Tests', () {
    test('Auth Service Function: "getCurrentUser() - Should return current user as User Model"', () async {
      // Create a mock user in auth
      final mockUser = MockUser(
        uid: testUid,
        email: testEmail,
        displayName: '$testFirstName $testLastName', // Add displayName
      );
      
      // Setup the auth mock to return this user
      auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      
      // Create a fresh authService with our configured auth
      authService = AuthService(auth: auth, firestore: firestore);
      
      // Create user document directly in firestore with firstName and lastName
      await firestore.collection('users').doc(testUid).set({
        'id': testUid,
        'username': testEmail.split('@')[0],
        'firstName': testFirstName,
        'lastName': testLastName,
        'email': testEmail,
        'photoUrl': null,
        'privateMode': false,
        'enableAiMealAnalysis': true,
        'blockedUsers': [],
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
      });
      
      // Call getCurrentUser() from the AuthService
      final userModel = await authService.getCurrentUser();
      
      // Verify the resulting UserModel
      expect(userModel, isNotNull);
      expect(userModel?.id, testUid);
      expect(userModel?.email, testEmail);
      expect(userModel?.username, testEmail.split('@')[0]);
      expect(userModel?.firstName, testFirstName);
      expect(userModel?.lastName, testLastName);
      expect(userModel?.photoUrl, null);
      expect(userModel?.privateMode, false);
      expect(userModel?.enableAiMealAnalysis, true);
      expect(userModel?.blockedUsers, []);
      expect(userModel?.createdAt, isNotNull);
      expect(userModel?.lastLogin, isNotNull);
    });

    test('Auth Service Function: "createUserWithEmailAndPassword()" - Should create a user with email and password', () async {
      // Create a user with firstName and lastName
      final UserModel? user = await authService.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
        firstName: testFirstName,
        lastName: testLastName
      );
      
      // Verify user was created
      expect(user, isNotNull);
      
      // Verify user document exists in Firestore
      final userDoc = await firestore.collection('users').doc(user!.id).get();
      expect(userDoc.exists, true);
      
      // Verify user data
      final userData = userDoc.data();
      expect(userData?['email'], testEmail);
      expect(userData?['username'], testEmail.split('@')[0]);
      expect(userData?['firstName'], testFirstName);
      expect(userData?['lastName'], testLastName);
      //expect(userData?['photoUrl'], null);
      expect(userData?['privateMode'], false);
      expect(userData?['enableAiMealAnalysis'], true);
      expect(userData?['blockedUsers'], []);
      expect(userData?['createdAt'], isNotNull);
      expect(userData?['lastLogin'], isNotNull);
      
      // Verify display name was updated
      expect(auth.currentUser?.displayName, '$testFirstName $testLastName');
    });

    test('Auth Service Function: "signInWithEmailAndPassword()" - Should sign in with email and password', () async {
      // First create a user
      final mockUser = MockUser(
        uid: testUid,
        email: testEmail,
        displayName: '$testFirstName $testLastName',
      );
      auth = MockFirebaseAuth(mockUser: mockUser);
      authService = AuthService(auth: auth, firestore: firestore);
      
      // Create user in Firestore
      await authService.createNewUser(
        testUid,
        testEmail,
        testFirstName,
        testLastName,
        null
      );
      
      // Sign out
      await auth.signOut();
      
      // Test sign in
      final UserModel? signedInUser = await authService.signInWithEmailAndPassword(
        testEmail, 
        testPassword
      );
      
      expect(signedInUser, isNotNull);
      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser?.email, testEmail);
      expect(signedInUser?.id, testUid);
    });

    test('Auth Service Function: "signInWithGoogle" - Should sign in with Google', () async {
      // Configure mock user for Google sign-in
      final mockUser = MockUser(
        uid: 'google-user-id',
        email: 'google@example.com',
        displayName: 'Google User',
        photoURL: 'https://example.com/photo.jpg'
      );
      auth = MockFirebaseAuth(mockUser: mockUser);
      authService = AuthService(auth: auth, firestore: firestore);
      
      // Set up Google Sign In mock
      final UserModel? user = await authService.signInWithGoogle(googleSignIn);
      
      expect(user, isNotNull);
      expect(auth.currentUser, isNotNull);
      
      // Verify user was created in Firestore
      if (auth.currentUser != null) {
        final userDoc = await firestore.collection('users').doc(auth.currentUser!.uid).get();
        expect(userDoc.exists, true);
        
        // Check user data
        final userData = userDoc.data();
        expect(userData?['email'], 'google@example.com');
        expect(userData?['firstName'], 'Google');
        expect(userData?['lastName'], 'User');
        expect(userData?['photoUrl'], 'https://example.com/photo.jpg');
      }
    });

    // Add test for verifyUserCredential helper
    test('Auth Service Function: "verifyUserCredential" - Should process user credential properly', () async {
      // Create a user in Firestore first
      final mockUser = MockUser(
        uid: testUid,
        email: testEmail,
        displayName: '$testFirstName $testLastName',
      );
      
      // Configure auth to return this user on sign-in
      auth = MockFirebaseAuth(mockUser: mockUser);
      authService = AuthService(auth: auth, firestore: firestore);
      
      // Sign in to get a real UserCredential
      final UserCredential mockCredential = await auth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword
      );
      
      // Test verifyUserCredential with new user
      final UserModel? user = await authService.verifyUserCredential(mockCredential);
      
      expect(user, isNotNull);
      
      // Verify user was created in Firestore
      final userDoc = await firestore.collection('users').doc(testUid).get();
      expect(userDoc.exists, true);
    });

    test('Auth Service Function: "updateUser" - Should update existing user', () async {
      // Create a user in Firestore first
      final mockUser = MockUser(
        uid: testUid,
        email: testEmail,
        displayName: '$testFirstName $testLastName',
      );

      // Configure auth to return this user on sign-in
      auth = MockFirebaseAuth(mockUser: mockUser);
      authService = AuthService(auth: auth, firestore: firestore);
      
      // Sign in to get a real UserCredential
      final UserCredential mockCredential = await auth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword
      );
          
      // Create the user document
      await firestore.collection('users').doc(testUid).set({
        'id': testUid,
        'username': testEmail.split('@')[0],
        'firstName': testFirstName,
        'lastName': testLastName,
        'email': testEmail,
        'photoUrl': null,
        'privateMode': false,
        'enableAiMealAnalysis': true,
        'blockedUsers': [],
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(), // Old login time
      });
      
      // Update the user
      final result = await authService.updateUser(mockCredential);
      expect(result, true);
      
      // Verify the lastLogin time was updated
      final userDoc = await firestore.collection('users').doc(testUid).get();
      final userData = userDoc.data();
      final lastLogin = DateTime.parse(userData?['lastLogin']);
      
      // Last login should be recent (within last minute)
      expect(DateTime.parse(DateTime.now().toIso8601String()).difference(lastLogin).inMinutes < 1, true);
    });

    test('Auth Service Function: "updateLastLoginTime" - Should update timestamp', () async {
      // Create a user document with old login time
      await firestore.collection('users').doc(testUid).set({
        'id': testUid,
        'username': testEmail.split('@')[0],
        'firstName': testFirstName,
        'lastName': testLastName,
        'email': testEmail,
        'lastLogin': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      });
      
      // Update last login time
      final result = await authService.updateLastLoginTime(testUid);
      expect(result, true);
      
      // Verify timestamp was updated
      final userDoc = await firestore.collection('users').doc(testUid).get();
      final userData = userDoc.data();
      final lastLogin = DateTime.parse(userData?['lastLogin']);
      
      // Should be updated within the last minute
      expect(DateTime.now().difference(lastLogin).inMinutes < 1, true);
    });

    test('Auth Service Function: "createNewUser" - Should create new user document', () async {
      // Create a new user
      final result = await authService.createNewUser(
        'new-user-id',
        'newuser@example.com',
        'New',
        'User',
        'https://example.com/newphoto.jpg'
      );
      
      expect(result, true);
      
      // Verify user document was created
      final userDoc = await firestore.collection('users').doc('new-user-id').get();
      expect(userDoc.exists, true);
      
      // Verify user data
      final userData = userDoc.data();
      expect(userData?['email'], 'newuser@example.com');
      expect(userData?['firstName'], 'New');
      expect(userData?['lastName'], 'User');
      expect(userData?['photoUrl'], 'https://example.com/newphoto.jpg');
    });

    test('Auth Service Function: "signOut" - Should sign out current user', () async {
      // Setup a signed-in user
      final mockUser = MockUser(
        uid: testUid,
        email: testEmail,
      );
      auth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      authService = AuthService(auth: auth, firestore: firestore);
      
      // Verify user is signed in
      expect(auth.currentUser, isNotNull);
      
      // Sign out
      await authService.signOut();
      
      // Verify user is signed out
      expect(auth.currentUser, isNull);
    });

  
  });
}