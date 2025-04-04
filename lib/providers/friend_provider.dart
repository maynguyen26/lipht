import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:lipht/data/models/user_model.dart';
import 'package:lipht/data/repositories/friend_repository.dart';

class FriendProvider extends ChangeNotifier {
  final FriendRepository _friendRepository;
  final String _userId;
  String get userId => _userId;

  FriendProvider(this._friendRepository, this._userId) {
    _listenToFriends();
    _listenToIncomingRequests();
    _listenToOutgoingRequests();
  }

  // State variables
  List<UserModel> _friends = [];
  List<UserModel> _incomingRequests = [];
  List<UserModel> _outgoingRequests = [];
  List<UserModel> _searchResults = [];
  bool _isLoadingFriends = true;
  bool _isLoadingIncomingRequests = true;
  bool _isLoadingOutgoingRequests = true;
  bool _isSearching = false;
  bool _isPerformingAction = false; // For add/accept/reject/remove
  String? _error;

  // Stream Subscriptions
  StreamSubscription? _friendsSubscription;
  StreamSubscription? _incomingRequestsSubscription;
  StreamSubscription? _outgoingRequestsSubscription;

  // Getters
  List<UserModel> get friends => _friends;
  List<UserModel> get incomingRequests => _incomingRequests;
  List<UserModel> get outgoingRequests => _outgoingRequests;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoadingFriends => _isLoadingFriends;
  bool get isLoadingIncomingRequests => _isLoadingIncomingRequests;
  bool get isLoadingOutgoingRequests => _isLoadingOutgoingRequests;
  bool get isSearching => _isSearching;
  bool get isPerformingAction => _isPerformingAction;
  String? get error => _error;

  // --- Stream Listeners ---

  void _listenToFriends() {
    _isLoadingFriends = true;
    notifyListeners();
    _friendsSubscription?.cancel(); // Cancel previous subscription
    _friendsSubscription =
        _friendRepository.getFriendsStream(_userId).listen((friendsList) {
      _friends = friendsList;
      _isLoadingFriends = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = "Error fetching friends: $e";
      _isLoadingFriends = false;
      _friends = []; // Clear list on error
      notifyListeners();
    });
  }

  void _listenToIncomingRequests() {
    _isLoadingIncomingRequests = true;
    notifyListeners();
    _incomingRequestsSubscription?.cancel();
    _incomingRequestsSubscription = _friendRepository
        .getIncomingRequestsStream(_userId)
        .listen((requestsList) {
      _incomingRequests = requestsList;
      _isLoadingIncomingRequests = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = "Error fetching incoming requests: $e";
      _isLoadingIncomingRequests = false;
      _incomingRequests = [];
      notifyListeners();
    });
  }

  void _listenToOutgoingRequests() {
    _isLoadingOutgoingRequests = true;
    notifyListeners();
    _outgoingRequestsSubscription?.cancel();
    _outgoingRequestsSubscription = _friendRepository
        .getOutgoingRequestsStream(_userId)
        .listen((requestsList) {
      _outgoingRequests = requestsList;
      _isLoadingOutgoingRequests = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = "Error fetching outgoing requests: $e";
      _isLoadingOutgoingRequests = false;
      _outgoingRequests = [];
      notifyListeners();
    });
  }

  // --- Search ---

  Future<void> searchUsers(String query) async {
    print("FRIEND_PROVIDER: searchUsers CALLED with query: '$query'");
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _friendRepository.searchUsers(query, _userId);
    } catch (e) {
      _error = "Search failed: $e";
      _searchResults = []; // Clear results on error
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  // --- Actions ---

  Future<bool> sendFriendRequest(String recipientId) async {
    return _performAction(
        () => _friendRepository.sendFriendRequest(_userId, recipientId));
  }

  Future<bool> acceptFriendRequest(String senderId) async {
    return _performAction(
        () => _friendRepository.acceptFriendRequest(_userId, senderId));
  }

  Future<bool> rejectFriendRequest(String senderId) async {
    return _performAction(
        () => _friendRepository.rejectFriendRequest(_userId, senderId));
  }

  Future<bool> cancelFriendRequest(String recipientId) async {
    return _performAction(
        () => _friendRepository.cancelFriendRequest(_userId, recipientId));
  }

  Future<bool> removeFriend(String friendId) async {
    return _performAction(
        () => _friendRepository.removeFriend(_userId, friendId));
  }

  // Helper for performing actions with loading state and error handling
  Future<bool> _performAction(Future<void> Function() action) async {
    _isPerformingAction = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      // Streams will automatically update the lists, no need to manually refresh here
      return true;
    } catch (e) {
      _error = "Action failed: $e";
      return false;
    } finally {
      _isPerformingAction = false;
      notifyListeners();
    }
  }

  // --- Status Check ---
  Future<String?> getFriendshipStatus(String otherUserId) async {
    try {
      return await _friendRepository.getFriendshipStatus(_userId, otherUserId);
    } catch (e) {
      print("Error getting friendship status: $e");
      return null;
    }
  }

  // Dispose subscriptions
  @override
  void dispose() {
    _friendsSubscription?.cancel();
    _incomingRequestsSubscription?.cancel();
    _outgoingRequestsSubscription?.cancel();
    super.dispose();
  }
}
