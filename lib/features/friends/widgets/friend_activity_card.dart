import 'package:flutter/material.dart';
import 'package:lipht/data/models/user_model.dart';
import 'package:lipht/data/repositories/friend_repository.dart';
import 'package:provider/provider.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendActivityCard extends StatefulWidget {
  final UserModel friend;

  const FriendActivityCard({
    Key? key,
    required this.friend,
  }) : super(key: key);

  @override
  _FriendActivityCardState createState() => _FriendActivityCardState();
}

class _FriendActivityCardState extends State<FriendActivityCard> {
  FriendActivityInfo? _latestActivity;
  bool _isLoadingActivity = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchActivity();
      }
    });
  }

  Future<void> _fetchActivity() async {
    if (!mounted) return;

    setState(() {
      _isLoadingActivity = true;
      _errorMessage = '';
    });

    try {
      final friendRepo = FriendRepository();
      final activity =
          await friendRepo.getLatestFriendActivity(widget.friend.id);

      if (mounted) {
        setState(() {
          _latestActivity = activity;
          _isLoadingActivity = false;
        });
      }
    } catch (e) {
      print("Error fetching activity for ${widget.friend.id} in Widget: $e");
      if (mounted) {
        setState(() {
          _isLoadingActivity = false;
          _errorMessage = "Couldn't load activity";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayActivity = "No recent activity";
    IconData activityIcon = Icons.notifications_off_outlined;
    String relativeTime = "";
    Widget activityWidget;

    if (_isLoadingActivity) {
      activityWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary)),
          const SizedBox(width: 8),
          Text("Loading activity...",
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      );
    } else if (_errorMessage.isNotEmpty) {
      activityWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.redAccent),
          const SizedBox(width: 8),
          Text(_errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.redAccent)),
        ],
      );
    } else if (_latestActivity != null) {
      displayActivity = _latestActivity!.summary;
      activityIcon = _getActivityIcon(_latestActivity!.type);
      DateTime activityDate = _latestActivity!.timestamp.toDate();
      relativeTime = GetTimeAgo.parse(activityDate);

      activityWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(activityIcon,
              size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              displayActivity,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            relativeTime,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      );
    } else {
      activityWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text("No recent activity",
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 28,
              backgroundImage: widget.friend.photoUrl != null
                  ? NetworkImage(widget.friend.photoUrl!)
                  : null,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: widget.friend.photoUrl == null
                  ? const Icon(Icons.person, size: 28)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.friend.firstName} ${widget.friend.lastName}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "@${widget.friend.username}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  activityWidget,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String? activityType) {
    switch (activityType?.toLowerCase()) {
      case 'workout':
        return Icons.fitness_center;
      case 'sleep':
        return Icons.bedtime_outlined;
      case 'meal':
        return Icons.restaurant_menu;
      default:
        return Icons.notifications_active_outlined;
    }
  }
}
