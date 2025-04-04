import 'package:flutter/material.dart';
import 'package:lipht/data/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/friend_provider.dart';

class UserSearchResultItem extends StatefulWidget {
  final UserModel user;

  const UserSearchResultItem({Key? key, required this.user}) : super(key: key);

  @override
  State<UserSearchResultItem> createState() => _UserSearchResultItemState();
}

class _UserSearchResultItemState extends State<UserSearchResultItem> {
  String? _friendshipStatus;
  bool _isLoadingStatus = true;
  bool _isActionLoading = false; 

  @override
  void initState() {
    super.initState();
    _checkFriendshipStatus();
  }

  Future<void> _checkFriendshipStatus() async {
    if (!mounted) return;
    setState(() {
      _isLoadingStatus = true;
    });
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    final status = await friendProvider.getFriendshipStatus(widget.user.id);
    if (mounted) {
      setState(() {
        _friendshipStatus = status;
        _isLoadingStatus = false;
      });
    }
  }

  Future<void> _performAction(Future<bool> Function() action) async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);
    await action();
    // Re-check status after action
    await _checkFriendshipStatus();
    if (mounted) {
      setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);

    Widget trailingWidget;

    if (_isLoadingStatus || _isActionLoading) {
      trailingWidget = SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2));
    } else {
      switch (_friendshipStatus) {
        case 'accepted':
          trailingWidget = Icon(Icons.check,
              color: Colors.green, semanticLabel: 'Already friends');
          break;
        case 'pending_outgoing':
          trailingWidget = TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.orange)),
            onPressed: () => _performAction(
                () => friendProvider.cancelFriendRequest(widget.user.id)),
          );
          break;
        case 'pending_incoming':
          trailingWidget = TextButton(
            child: Text('Accept', style: TextStyle(color: Colors.green)),
            onPressed: () => _performAction(
                () => friendProvider.acceptFriendRequest(widget.user.id)),
          );
          break;
        default: // No existing relationship or blocked (handle block later)
          trailingWidget = IconButton(
            icon: Icon(Icons.person_add_alt_1_outlined,
                color: Theme.of(context).colorScheme.primary),
            tooltip: 'Send Friend Request',
            onPressed: () => _performAction(
                () => friendProvider.sendFriendRequest(widget.user.id)),
          );
      }
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: widget.user.photoUrl != null
            ? NetworkImage(widget.user.photoUrl!)
            : null,
        child: widget.user.photoUrl == null ? Icon(Icons.person) : null,
      ),
      title: Text("${widget.user.firstName} ${widget.user.lastName}"),
      subtitle: Text("@${widget.user.username}"),
      trailing: trailingWidget,
    );
  }
}
