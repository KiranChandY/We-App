import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AllMembersScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _allMembers = [
    {'id': '1', 'name': 'John Doe', 'email': 'john@example.com', 'avatar': 'J', 'role': 'Admin'},
    {'id': '2', 'name': 'Jane Smith', 'email': 'jane@example.com', 'avatar': 'J', 'role': 'Member'},
    {'id': '3', 'name': 'Bob Wilson', 'email': 'bob@example.com', 'avatar': 'B', 'role': 'Member'},
    {'id': '4', 'name': 'Alice Brown', 'email': 'alice@example.com', 'avatar': 'A', 'role': 'Member'},
    {'id': '5', 'name': 'Charlie Davis', 'email': 'charlie@example.com', 'avatar': 'C', 'role': 'Member'},
  ];

  AllMembersScreen({super.key});

  void _inviteMembers(BuildContext context) {
    Share.share(
      'Join our event sharing app! Download it now and stay connected with your friends and family.',
      subject: 'Invitation to join WE App',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Members',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _inviteMembers(context),
                icon: const Icon(Icons.person_add),
                label: const Text('Invite'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _allMembers.length,
            itemBuilder: (context, index) {
              final member = _allMembers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.white.withOpacity(0.1),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(member['avatar']),
                  ),
                  title: Text(member['name']),
                  subtitle: Text(member['email']),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: member['role'] == 'Admin' 
                          ? Colors.deepPurple.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      member['role'],
                      style: TextStyle(
                        color: member['role'] == 'Admin'
                            ? Colors.deepPurple
                            : Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 