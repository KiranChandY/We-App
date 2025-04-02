import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  final ImagePicker _picker = ImagePicker();
  File? _eventPhoto;
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

  void _showMemberSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Select Members',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          onChanged: (query) {
                            setState(() {
                              _searchMembers(query);
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search members...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final member = _searchResults[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: member['selected']
                                  ? Colors.deepPurple
                                  : Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          color: member['selected']
                              ? Colors.deepPurple.withOpacity(0.1)
                              : Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: member['selected']
                                  ? Colors.deepPurple
                                  : Colors.deepPurple.withOpacity(0.1),
                              child: Text(
                                member['avatar'],
                                style: TextStyle(
                                  color: member['selected'] ? Colors.white : Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              member['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(member['email']),
                            trailing: IconButton(
                              icon: Icon(
                                member['selected']
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: member['selected']
                                    ? Colors.deepPurple
                                    : Colors.grey,
                                size: 28,
                              ),
                              onPressed: () {
                                setState(() {
                                  _toggleMemberSelection(member);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Selected: ${_selectedMembers.length} members',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {});
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Add Selected'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _proceedToEventDetails() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(
            eventId: DateTime.now().millisecondsSinceEpoch.toString(),
            eventTitle: _titleController.text,
            eventPhoto: _eventPhoto,
          ),
        ),
      );
    }
  }

  void _inviteMembers() {
    Share.share(
      'Join our event sharing app! Download it now and stay connected with your friends and family.',
      subject: 'Invitation to join WE App',
    );
  }

  Future<void> _pickEventPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _eventPhoto = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create New Event'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event Title
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Event Title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an event title';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Event Photo
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Event Photo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _pickEventPhoto,
                                  child: Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.deepPurple.withOpacity(0.2),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: _eventPhoto == null
                                        ? Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurple.withOpacity(0.05),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.add_photo_alternate_rounded,
                                                  size: 48,
                                                  color: Colors.deepPurple.withOpacity(0.8),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Add Event Photo',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.deepPurple.withOpacity(0.8),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Tap to choose a photo from your gallery',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          )
                                        : Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(16),
                                                child: Image.file(
                                                  _eventPhoto!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(16),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.black.withOpacity(0.3),
                                                      Colors.black.withOpacity(0.1),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 12,
                                                right: 12,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.9),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.1),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color: Colors.deepPurple,
                                                      size: 20,
                                                    ),
                                                    onPressed: _pickEventPhoto,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                if (_eventPhoto != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tap the edit icon to change the photo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  title: const Text(
                                    'Event Members',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  trailing: FilledButton.icon(
                                    onPressed: _showMemberSelectionSheet,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Members'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_selectedMembers.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          color: Colors.grey[600],
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'No members added yet',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(12),
                                      ),
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _selectedMembers.length,
                                      itemBuilder: (context, index) {
                                        final member = _selectedMembers[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.deepPurple.withOpacity(0.1),
                                            child: Text(
                                              member['avatar'],
                                              style: const TextStyle(
                                                color: Colors.deepPurple,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          title: Text(member['name']),
                                          subtitle: Text(member['email']),
                                          trailing: IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                member['selected'] = false;
                                                _selectedMembers.remove(member);
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: FilledButton(
                onPressed: _selectedMembers.isNotEmpty ? _proceedToEventDetails : null,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to Event Details',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 