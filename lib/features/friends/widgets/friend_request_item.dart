import 'package:flutter/material.dart';
import 'package:lipht/data/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/friend_provider.dart';

enum RequestType { incoming, outgoing }

class FriendRequestItem extends StatelessWidget {
  final UserModel user;
  final RequestType type;

  const FriendRequestItem({
    Key? key,
    required this.user,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
        child: user.photoUrl == null ? Icon(Icons.person) : null,
      ),
      title: Text("${user.firstName} ${user.lastName}"),
      subtitle: Text("@${user.username}"),
      trailing: type == RequestType.incoming
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check_circle_outline, color: Colors.green),
                  tooltip: 'Accept',
                  onPressed: () => friendProvider.acceptFriendRequest(user.id),
                ),
                IconButton(
                  icon: Icon(Icons.cancel_outlined, color: Colors.red),
                  tooltip: 'Reject',
                  onPressed: () => friendProvider.rejectFriendRequest(user.id),
                ),
              ],
            )
          : TextButton(
              // For outgoing requests
              child: Text('Cancel', style: TextStyle(color: Colors.orange)),
              onPressed: () => friendProvider.cancelFriendRequest(user.id),
            ),
    );
  }
}
