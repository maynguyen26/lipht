import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/friend_provider.dart';
import 'package:lipht/providers/auth_provider.dart' as app_auth;
import 'package:lipht/features/friends/widgets/friend_list_item.dart';
import 'package:lipht/features/friends/widgets/friend_request_item.dart';
import 'package:lipht/features/friends/widgets/user_search_result_item.dart';
import 'package:lipht/features/friends/widgets/friend_activity_card.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty != _showClearButton) {
        setState(() {
          _showClearButton = _searchController.text.isNotEmpty;
        });
      }
      final friendProvider =
          Provider.of<FriendProvider?>(context, listen: false);
      if (friendProvider != null) {
        friendProvider.searchUsers(_searchController.text);
      } else {
        print("FriendProvider not available for search.");
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    if (friendProvider != null) {
      friendProvider.clearSearch();
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendProvider?>(
      builder: (context, friendProvider, child) {
        if (friendProvider == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Loading user data...")
              ],
            ),
          );
        }

        // If provider exists, build the UI
        return Scaffold(
          backgroundColor: const Color(0xFFF9EDFF),
          appBar: TabBar(
            controller: _tabController,
            indicatorColor: Color(0xFFA764FF),
            labelColor: Color(0xFFA764FF),
            unselectedLabelColor: Color(0xFF9D76C1),
            tabs: const [
              Tab(text: 'Activity'),
              Tab(text: 'Friends'),
              Tab(text: 'Requests'),
              Tab(text: 'Search'),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildFriendsActivityList(friendProvider),
              _buildFriendsList(friendProvider),
              _buildRequestsList(friendProvider),
              _buildSearchUsers(friendProvider),
            ],
          ),
        );
      },
    );
  }

  // --- Build Methods for Tabs ---

  Widget _buildFriendsList(FriendProvider provider) {
    if (provider.isLoadingFriends) {
      return Center(child: CircularProgressIndicator(color: Color(0xFFA764FF)));
    }
    if (provider.friends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_add_outlined,
                size: 60,
                color: Color(0xFF9D76C1).withOpacity(0.7),
              ),
              SizedBox(height: 20),
              Text(
                "Your friend list is empty",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9D76C1),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Find and add friends to see their progress!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9D76C1).withOpacity(0.8),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.search, size: 20),
                label: Text("Find Friends"),
                onPressed: () {
                  _tabController.animateTo(3);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA764FF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: provider.friends.length,
      itemBuilder: (context, index) {
        return FriendListItem(friend: provider.friends[index]);
      },
    );
  }

  Widget _buildFriendsActivityList(FriendProvider provider) {
    if (provider.isLoadingFriends) {
      return Center(child: CircularProgressIndicator(color: Color(0xFFA764FF)));
    }

    if (provider.friends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dynamic_feed,
                size: 60,
                color: Color(0xFF9D76C1).withOpacity(0.7),
              ),
              SizedBox(height: 20),
              Text(
                "No Friend Activity Yet",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9D76C1),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Add some friends to see what they're up to!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9D76C1).withOpacity(0.8),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.search, size: 20),
                label: Text("Find Friends"),
                onPressed: () {
                  _tabController.animateTo(3);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA764FF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: provider.friends.length,
      itemBuilder: (context, index) {
        final friend = provider.friends[index];
        return FriendActivityCard(
          friend: friend,
        );
      },
    );
  }

  Widget _buildRequestsList(FriendProvider provider) {
    if (provider.isLoadingIncomingRequests ||
        provider.isLoadingOutgoingRequests) {
      return Center(child: CircularProgressIndicator(color: Color(0xFFA764FF)));
    }

    final incoming = provider.incomingRequests;
    final outgoing = provider.outgoingRequests;

    if (incoming.isEmpty && outgoing.isEmpty) {
      return Center(
          child: Text("No pending friend requests.",
              style: TextStyle(color: Color(0xFF9D76C1))));
    }

    return ListView(children: [
      if (incoming.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Incoming Requests",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9D76C1))),
        ),
        ...incoming
            .map((user) =>
                FriendRequestItem(user: user, type: RequestType.incoming))
            .toList(),
        if (outgoing.isNotEmpty)
          Divider(
              thickness: 1, height: 32),
      ],
      if (outgoing.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Sent Requests",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9D76C1))),
        ),
        ...outgoing
            .map((user) =>
                FriendRequestItem(user: user, type: RequestType.outgoing))
            .toList(),
      ]
    ]);
  }

  Widget _buildSearchUsers(FriendProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search by username...",
              prefixIcon: Icon(Icons.search, color: Color(0xFF9D76C1)),
              suffixIcon: _showClearButton
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Color(0xFF9D76C1)),
                      onPressed: _clearSearch,
                    )
                  : null,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Color(0xFFA764FF), width: 2)),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            ),
            
            textInputAction: TextInputAction.search,
            onSubmitted: (query) {
              final friendProvider =
                  Provider.of<FriendProvider?>(context, listen: false);

              if (friendProvider == null) {
                print(
                    "SUBMIT ERROR: friendProvider is NULL!");
              } else {

                if (query.isNotEmpty) {
                  provider.searchUsers(query);
                } else {
                  provider.clearSearch();
                }
              }
            },
          ),
          SizedBox(height: 16),
          Expanded(
            child: provider.isSearching
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFFA764FF)))
                : provider.searchResults.isEmpty &&
                        _searchController.text.isNotEmpty
                    ? Center(
                        child: Text("No users found.",
                            style: TextStyle(color: Color(0xFF9D76C1))))
                    : ListView.builder(
                        itemCount: provider.searchResults.length,
                        itemBuilder: (context, index) {
                          return UserSearchResultItem(
                              user: provider.searchResults[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
