import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lipht/data/models/user_model.dart';
import 'package:lipht/core/services/auth_service.dart';
import 'package:intl/intl.dart';

class FriendActivityInfo {
  final String summary;
  final String type; // e.g., 'workout', 'meal', 'sleep'
  final Timestamp timestamp;

  FriendActivityInfo(
      {required this.summary, required this.type, required this.timestamp});
}

class FriendRepository {
  final FirebaseFirestore _firestore;
  final AuthService
      _authService; 

  FriendRepository({FirebaseFirestore? firestore, AuthService? authService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService =
            authService ?? AuthService(); 

  // --- Fetching Data ---

  // Get users who are friends (status == 'accepted')
  Stream<List<UserModel>> getFriendsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friendships')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((snapshot) async {
      final friendIds = snapshot.docs.map((doc) => doc.id).toList();
      return _fetchUserModels(friendIds);
    });
  }

  // Get incoming friend requests (status == 'pending_incoming')
  Stream<List<UserModel>> getIncomingRequestsStream(String userId) {
    print("REPO: getIncomingRequestsStream CALLED for user: $userId");
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friendships')
        .where('status', isEqualTo: 'pending_incoming')
        .snapshots()
        .asyncMap((snapshot) async {
      print(
          "REPO (Stream): Snapshot received with ${snapshot.docs.length} docs.");
      if (snapshot.metadata.hasPendingWrites) {
        print("REPO (Stream): Snapshot has pending writes.");
      }
      final requestorIds = snapshot.docs.map((doc) {
        print(
            "REPO (Stream): Found matching doc ID: ${doc.id}, Data: ${doc.data()}");
        return doc.id;
      }).toList();

      print("REPO (Stream): Extracted requestor IDs: $requestorIds");
      return await _fetchUserModels(requestorIds);
    }).handleError((error) {
      print(
          "REPO (Stream): ERROR in stream processing (asyncMap or snapshots): $error");
      return <UserModel>[];
    });
  }

  // Get outgoing friend requests (status == 'pending_outgoing')
  Stream<List<UserModel>> getOutgoingRequestsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friendships')
        .where('status', isEqualTo: 'pending_outgoing')
        .snapshots()
        .asyncMap((snapshot) async {
      final recipientIds = snapshot.docs.map((doc) => doc.id).toList();
      return _fetchUserModels(recipientIds);
    });
  }

  // Helper to fetch user models from a list of IDs
  Future<List<UserModel>> _fetchUserModels(List<String> userIds) async {
    print("REPO: _fetchUserModels called with IDs: $userIds");
    if (userIds.isEmpty) {
      print("REPO: _fetchUserModels received empty ID list, returning empty.");
      return [];
    }
    try {
      final List<UserModel> users = [];
      for (String id in userIds) {
        print("REPO: Fetching user model for ID: $id");
        final userDoc = await _firestore.collection('users').doc(id).get();
        if (userDoc.exists) {
          print("REPO: User doc exists for ID: $id");
          try {
            users.add(
                UserModel.fromJson({'id': userDoc.id, ...userDoc.data()!}));
          } catch (e) {
            print("REPO: ERROR parsing UserModel for ID $id: $e");
          }
        } else {
          print("REPO: WARNING - User doc NOT FOUND for ID: $id");
        }
      }
      print("REPO: _fetchUserModels returning ${users.length} users.");
      return users;
    } catch (e) {
      print("REPO: ERROR in _fetchUserModels during Firestore fetch: $e");
      return []; 
    }
  }

  // --- Searching Users ---

  Future<List<UserModel>> searchUsers(
      String query, String currentUserId) async {
    print(
        "FRIEND_REPOSITORY: searchUsers CALLED with query: '$query', userId: '$currentUserId'");
    if (query.isEmpty) {
      print("FRIEND_REPOSITORY: Query empty, returning early.");
      return [];
    }

    final queryLower = query.toLowerCase();

    // Search by username (primary) 
    final usernameSnapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: queryLower)
        .where('username', isLessThanOrEqualTo: queryLower + '\uf8ff')
        .limit(10) // Limit results for performance
        .get();

    final users = usernameSnapshot.docs
        .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()!}))
        .where((user) => user.id != currentUserId) // Exclude self
        .toList();

    return users;
  }

  // --- Modifying Friendships ---

  Future<void> sendFriendRequest(String senderId, String recipientId) async {
    print(
        "REPOSITORY: sendFriendRequest CALLED. Sender: $senderId, Recipient: $recipientId");
    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();

    // Sender's perspective
    final senderRef = _firestore
        .collection('users')
        .doc(senderId)
        .collection('friendships')
        .doc(recipientId);
    batch.set(senderRef, {'status': 'pending_outgoing', 'timestamp': now});

    // Recipient's perspective
    final recipientRef = _firestore
        .collection('users')
        .doc(recipientId)
        .collection('friendships')
        .doc(senderId);
    batch.set(recipientRef, {'status': 'pending_incoming', 'timestamp': now});

    await batch.commit();
  }

  Future<void> acceptFriendRequest(String userId, String senderId) async {
    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();

    // User's perspective (accepting)
    final userRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('friendships')
        .doc(senderId);
    batch.update(userRef, {'status': 'accepted', 'timestamp': now});

    // Sender's perspective (being accepted)
    final senderRef = _firestore
        .collection('users')
        .doc(senderId)
        .collection('friendships')
        .doc(userId);
    batch.update(senderRef, {'status': 'accepted', 'timestamp': now});

    await batch.commit();
  }

  Future<void> rejectFriendRequest(String userId, String senderId) async {
    final batch = _firestore.batch();

    // Remove from user's requests
    final userRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('friendships')
        .doc(senderId);
    batch.delete(userRef);

    // Remove from sender's outgoing requests
    final senderRef = _firestore
        .collection('users')
        .doc(senderId)
        .collection('friendships')
        .doc(userId);
    batch.delete(senderRef);

    await batch.commit();
  }

  Future<void> cancelFriendRequest(String senderId, String recipientId) async {
    await rejectFriendRequest(recipientId, senderId);
  }

  Future<void> removeFriend(String userId, String friendId) async {
    final batch = _firestore.batch();

    // Remove from user's friends
    final userRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('friendships')
        .doc(friendId);
    batch.delete(userRef);

    // Remove from friend's friends
    final friendRef = _firestore
        .collection('users')
        .doc(friendId)
        .collection('friendships')
        .doc(userId);
    batch.delete(friendRef);

    await batch.commit();
  }

  // Add block/unblock logic here later

  // --- Checking Friendship Status ---

  Future<String?> getFriendshipStatus(String userId, String otherUserId) async {
    if (userId == otherUserId) return 'self'; 

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('friendships')
        .doc(otherUserId)
        .get();

    if (doc.exists) {
      return doc.data()?['status'] as String?;
    }
    return null;
  }

  // --- Fetching Friend Activity (Client-Side) ---

  Future<FriendActivityInfo?> getLatestFriendActivity(String friendId) async {
    print("REPO: getLatestFriendActivity called for friend: $friendId");
    try {
      // Fetch latest workout
      final workoutSnap = await _firestore
          .collection('users')
          .doc(friendId)
          .collection('workoutLogs')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      // Fetch latest meal
      final mealSnap = await _firestore
          .collection('users')
          .doc(friendId)
          .collection('mealLogs')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      // Fetch latest sleep
      final sleepSnap = await _firestore
          .collection('users')
          .doc(friendId)
          .collection('sleepLogs')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      // Store potential latest activities with their timestamps
      final List<Map<String, dynamic>> potentialActivities = [];

      if (workoutSnap.docs.isNotEmpty) {
        final data = workoutSnap.docs.first.data();
        if (data['timestamp'] != null) {
          potentialActivities.add({
            'timestamp': data['timestamp'] as Timestamp,
            'type': 'workout',
            'data': data,
          });
        }
      }
      if (mealSnap.docs.isNotEmpty) {
        final data = mealSnap.docs.first.data();
        if (data['timestamp'] != null) {
          potentialActivities.add({
            'timestamp': data['timestamp'] as Timestamp,
            'type': 'meal',
            'mealType': data['mealType'] as String? ?? 'meal',
            'data': data,
          });
        }
      }
      if (sleepSnap.docs.isNotEmpty) {
        final data = sleepSnap.docs.first.data();
        if (data['timestamp'] != null) {
          potentialActivities.add({
            'timestamp': data['timestamp'] as Timestamp,
            'type': 'sleep',
            'data': data,
          });
        }
      }

      if (potentialActivities.isEmpty) {
        print("REPO: No recent activity found for friend: $friendId");
        return null;
      }

      // Find the most recent one
      potentialActivities.sort((a, b) =>
          (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));
      final latestActivity = potentialActivities.first;

      String summary = "Logged an activity";
      final activityData = latestActivity['data'];
      final activityType = latestActivity['type'];
      final timestamp = latestActivity['timestamp'] as Timestamp;

      if (activityType == 'workout') {
        summary = "Logged workout: ${activityData['programName'] ?? 'Workout'}";
      } else if (activityType == 'meal') {
        final mealType = latestActivity['mealType'] ?? 'meal';
        summary =
            "Tracked ${mealType.replaceFirst(mealType[0], mealType[0].toUpperCase())}";
      } else if (activityType == 'sleep') {
        final durationMinutes = activityData['durationMinutes'] as int? ?? 0;
        final hours = durationMinutes ~/ 60;
        final minutes = durationMinutes % 60;
        summary = "Slept ${hours}h ${minutes.toString().padLeft(2, '0')}m";
      }

      print(
          "REPO: Latest activity for $friendId: $summary (Type: $activityType)");
      return FriendActivityInfo(
          summary: summary, type: activityType, timestamp: timestamp);
    } catch (e) {
      print("REPO: ERROR fetching latest activity for $friendId: $e");
      if (e.toString().contains('permission-denied')) {
        print(
            "REPO: PERMISSION DENIED - Check Firestore rules for reading friend's logs.");
      }
      return null;
    }
  }
}
