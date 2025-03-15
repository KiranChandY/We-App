import 'package:flutter/material.dart';
import 'event_details_screen.dart';

class EventMembersScreen extends StatefulWidget {
  const EventMembersScreen({
    super.key,
  });

  @override
  State<EventMembersScreen> createState() => _EventMembersScreenState();
}

class _EventMembersScreenState extends State<EventMembersScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _allMembers = [
    {'id': '1', 'name': 'John Doe', 'email': 'john@example.com', 'avatar': 'J', 'selected': false},
    {'id': '2', 'name': 'Jane Smith', 'email': 'jane@example.com', 'avatar': 'J', 'selected': false},
    {'id': '3', 'name': 'Bob Wilson', 'email': 'bob@example.com', 'avatar': 'B', 'selected': false},
    {'id': '4', 'name': 'Alice Brown', 'email': 'alice@example.com', 'avatar': 'A', 'selected': false},
    {'id': '5', 'name': 'Charlie Davis', 'email': 'charlie@example.com', 'avatar': 'C', 'selected': false},
  ];
  List<Map<String, dynamic>> _searchResults = [];
  final List<Map<String, dynamic>> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    _searchResults = List.from(_allMembers);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _searchMembers(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = List.from(_allMembers);
      } else {
        _searchResults = _allMembers
            .where((member) =>
                member['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
                member['email'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleMemberSelection(Map<String, dynamic> member) {
    setState(() {
      member['selected'] = !member['selected'];
      if (member['selected']) {
        _selectedMembers.add(member);
      } else {
        _selectedMembers.removeWhere((m) => m['id'] == member['id']);
      }
    });
  }

  void _proceedToEventDetails() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(
            eventId: DateTime.now().millisecondsSinceEpoch.toString(),
            eventTitle: _titleController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Event'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event title';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _searchMembers,
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final member = _searchResults[index];
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
                      trailing: IconButton(
                        icon: Icon(
                          member['selected'] ? Icons.check_circle : Icons.add_circle_outline,
                          color: member['selected'] ? Colors.green : null,
                        ),
                        onPressed: () => _toggleMemberSelection(member),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Selected Members: ${_selectedMembers.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectedMembers.isNotEmpty ? _proceedToEventDetails : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Continue to Event Details'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 