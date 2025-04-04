import 'package:flutter/material.dart';
import 'package:lipht/data/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:lipht/providers/friend_provider.dart';

class FriendListItem extends StatelessWidget {
  final UserModel friend;

  const FriendListItem({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            friend.photoUrl != null ? NetworkImage(friend.photoUrl!) : null,
        child: friend.photoUrl == null ? Icon(Icons.person) : null,
      ),
      title: Text("${friend.firstName} ${friend.lastName}"),
      subtitle: Text("@${friend.username}"),
      trailing: IconButton(
        icon: Icon(Icons.person_remove_alt_1_outlined, color: Colors.redAccent),
        tooltip: 'Remove Friend',
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Remove Friend'),
              content:
                  Text('Are you sure you want to remove ${friend.firstName}?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: Text('Remove', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Close dialog
                    Provider.of<FriendProvider>(context, listen: false)
                        .removeFriend(friend.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
      // Add onTap to view friend profile later
    );
  }
}
