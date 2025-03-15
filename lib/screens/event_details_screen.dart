import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/services.dart';
import 'photo_review_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final List<String> _images = []; // This will store image URLs from Firebase Storage
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _eventTitleController = TextEditingController();
  bool _receiveAlerts = true;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  final List<Map<String, dynamic>> _members = [
    {'id': '1', 'name': 'John Doe', 'email': 'john@example.com', 'avatar': 'J', 'role': 'Admin'},
    {'id': '2', 'name': 'Jane Smith', 'email': 'jane@example.com', 'avatar': 'J', 'role': 'Member'},
    {'id': '3', 'name': 'Mike Johnson', 'email': 'mike@example.com', 'avatar': 'M', 'role': 'Member'},
    {'id': '4', 'name': 'Sarah Williams', 'email': 'sarah@example.com', 'avatar': 'S', 'role': 'Member'},
  ];

  @override
  void initState() {
    super.initState();
    _eventTitleController.text = widget.eventTitle;
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    _eventTitleController.dispose();
    super.dispose();
  }

  void _showManageMembers() {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> filteredMembers = List.from(_members);

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
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Manage Members',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Total Members Count
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people, color: Colors.deepPurple, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Total Members: ${_members.length}',
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Search Bar
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search members...',
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          onChanged: (value) {
                            setState(() {
                              filteredMembers = _members.where((member) {
                                final name = member['name'].toString().toLowerCase();
                                final email = member['email'].toString().toLowerCase();
                                final searchTerm = value.toLowerCase();
                                return name.contains(searchTerm) || 
                                       email.contains(searchTerm);
                              }).toList();
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => _showInviteMemberDialog(),
                                icon: const Icon(Icons.person_add),
                                label: const Text('Invite Member'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => _showAddFromAppDialog(),
                                icon: const Icon(Icons.group_add),
                                label: const Text('Add from App'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          'Members',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.info_outline, size: 16, color: Colors.black54),
                        Expanded(
                          child: Text(
                            'Only admins can remove members',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        final bool isCurrentUserAdmin = true; // TODO: Replace with actual user role check
                        final bool isMemberAdmin = member['role'] == 'Admin';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isMemberAdmin ? Colors.deepPurple : Colors.grey[300],
                              child: Text(
                                member['avatar'],
                                style: TextStyle(
                                  color: isMemberAdmin ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            title: Text(
                              member['name'],
                              style: const TextStyle(color: Colors.black),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member['email'],
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isMemberAdmin 
                                      ? Colors.deepPurple.withOpacity(0.1)
                                      : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    member['role'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isMemberAdmin ? Colors.deepPurple : Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: isCurrentUserAdmin && !isMemberAdmin
                                ? PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'remove') {
                                        _showDeleteConfirmation(context, member);
                                      } else if (value == 'make_admin') {
                                        _showMakeAdminConfirmation(context, member);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      const PopupMenuItem<String>(
                                        value: 'make_admin',
                                        child: Row(
                                          children: [
                                            Icon(Icons.admin_panel_settings, size: 20),
                                            SizedBox(width: 8),
                                            Text('Make Admin'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'remove',
                                        child: Row(
                                          children: [
                                            Icon(Icons.remove_circle_outline, 
                                              color: Colors.red, 
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Remove',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        );
                      },
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

  void _showInviteMemberDialog() {
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invite Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter member\'s email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const Text(
                'Or share invite link:',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'https://weapp.com/events/${widget.eventId}',
                        style: const TextStyle(fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        final String inviteLink = 'https://weapp.com/events/${widget.eventId}';
                        await Clipboard.setData(ClipboardData(text: inviteLink));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copied to clipboard')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (emailController.text.isNotEmpty) {
                  // TODO: Implement email invitation
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invitation sent successfully')),
                  );
                }
              },
              child: const Text('Send Invite'),
            ),
          ],
        );
      },
    );
  }

  void _showMakeAdminConfirmation(BuildContext context, Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Make Admin'),
          content: Text('Are you sure you want to make ${member['name']} an admin? They will have full control over the event.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  member['role'] = 'Admin';
                });
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
                _showManageMembers(); // Reopen bottom sheet to show updated list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${member['name']} is now an admin')),
                );
              },
              child: const Text('Make Admin'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Member'),
          content: Text('Are you sure you want to remove ${member['name']} from this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _members.removeWhere((m) => m['id'] == member['id']);
                });
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
                _showManageMembers(); // Reopen bottom sheet to show updated list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Member removed successfully')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showAddFromAppDialog() {
    // Simulated list of app users
    final List<Map<String, dynamic>> appUsers = [
      {'id': '5', 'name': 'Emma Wilson', 'email': 'emma@example.com', 'avatar': 'E'},
      {'id': '6', 'name': 'James Brown', 'email': 'james@example.com', 'avatar': 'J'},
      {'id': '7', 'name': 'Olivia Davis', 'email': 'olivia@example.com', 'avatar': 'O'},
      {'id': '8', 'name': 'William Taylor', 'email': 'william@example.com', 'avatar': 'W'},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add from App'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: appUsers.length,
              itemBuilder: (context, index) {
                final user = appUsers[index];
                final bool isAlreadyMember = _members.any((m) => m['email'] == user['email']);
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Text(user['avatar']),
                  ),
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                  trailing: isAlreadyMember
                    ? const Text('Added',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: Colors.deepPurple,
                        onPressed: () {
                          setState(() {
                            _members.add({
                              ...user,
                              'role': 'Member',
                            });
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${user['name']} added to event')),
                          );
                        },
                      ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTimeFrameDialog() async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Time Frame',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please select the time frame from which you want to choose photos:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _startDateController,
                            readOnly: true,
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _startDate = picked;
                                  _startDateController.text = DateFormat('MMM dd, yyyy').format(picked);
                                });
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              suffixIcon: const Icon(Icons.calendar_today, color: Colors.black),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _startTimeController,
                            readOnly: true,
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: _startTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _startTime = picked;
                                  _startTimeController.text = picked.format(context);
                                });
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Time',
                              labelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              suffixIcon: const Icon(Icons.access_time, color: Colors.black),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'End',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _endDateController,
                            readOnly: true,
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _endDate = picked;
                                  _endDateController.text = DateFormat('MMM dd, yyyy').format(picked);
                                });
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              suffixIcon: const Icon(Icons.calendar_today, color: Colors.black),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _endTimeController,
                            readOnly: true,
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: _endTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _endTime = picked;
                                  _endTimeController.text = picked.format(context);
                                });
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Time',
                              labelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              suffixIcon: const Icon(Icons.access_time, color: Colors.black),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (_startDate != null && _startTime != null &&
                              _endDate != null && _endTime != null) {
                            // Combine date and time
                            final startDateTime = DateTime(
                              _startDate!.year,
                              _startDate!.month,
                              _startDate!.day,
                              _startTime!.hour,
                              _startTime!.minute,
                            );
                            final endDateTime = DateTime(
                              _endDate!.year,
                              _endDate!.month,
                              _endDate!.day,
                              _endTime!.hour,
                              _endTime!.minute,
                            );
                            
                            if (endDateTime.isBefore(startDateTime)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('End time must be after start time'),
                                ),
                              );
                              return;
                            }
                            
                            Navigator.pop(context);
                            _selectPhotos();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select both start and end date/time'),
                              ),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Select Photos',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectPhotos() async {
    // Request permission to access photos
    final PermissionState permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      // Get all photos
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      
      if (albums.isNotEmpty) {
        final List<AssetEntity> allPhotos = await albums.first.getAssetListRange(
          start: 0,
          end: 10000, // Adjust this number based on your needs
        );

        // Use the selected date/time values from the bottom sheet
        final startDateTime = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
          _startTime!.hour,
          _startTime!.minute,
        );
        final endDateTime = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          _endTime!.hour,
          _endTime!.minute,
        );

        // Filter photos by date range
        final List<AssetEntity> filteredPhotos = allPhotos.where((photo) {
          final DateTime photoDate = photo.createDateTime;
          return photoDate.isAfter(startDateTime) && 
                 photoDate.isBefore(endDateTime.add(const Duration(days: 1)));
        }).toList();

        if (filteredPhotos.isNotEmpty) {
          // Show the review screen
          final List<AssetEntity>? selectedPhotos = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoReviewScreen(
                selectedPhotos: filteredPhotos,
                startDate: startDateTime,
                endDate: endDateTime,
                members: _members.map((m) => m['name'] as String).toList(),
              ),
            ),
          );

          if (selectedPhotos != null && mounted) {
            setState(() {
              _images.addAll(selectedPhotos.map((photo) => photo.id));
            });
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No photos found in the selected date range'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission to access photos was denied'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _images.add(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _showEventSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Event Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Event Name Edit
                        ListTile(
                          leading: const Icon(Icons.edit, color: Colors.deepPurple),
                          title: const Text('Edit Event Name'),
                          subtitle: Text(widget.eventTitle),
                          onTap: () => _showEditEventNameDialog(),
                        ),
                        const Divider(),
                        
                        // Notifications Toggle
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications, color: Colors.deepPurple),
                          title: const Text('Receive Alerts'),
                          subtitle: const Text('Get notified about event updates'),
                          value: _receiveAlerts,
                          activeColor: Colors.deepPurple,
                          onChanged: (bool value) {
                            setState(() => _receiveAlerts = value);
                          },
                        ),
                        const Divider(),
                        
                        // Manage Members
                        ListTile(
                          leading: const Icon(Icons.people, color: Colors.deepPurple),
                          title: const Text('Add/Invite Members'),
                          subtitle: Text('${_members.length} members'),
                          onTap: () {
                            Navigator.pop(context);
                            _showManageMembers();
                          },
                        ),
                        const Divider(),
                        
                        // Invite Link
                        ListTile(
                          leading: const Icon(Icons.link, color: Colors.deepPurple),
                          title: const Text('Invite Link'),
                          subtitle: const Text('Share event link with others'),
                          onTap: () => _showInviteLinkDialog(),
                        ),
                        const Divider(),
                        
                        // Delete Event
                        ListTile(
                          leading: const Icon(Icons.delete_forever, color: Colors.red),
                          title: const Text('Delete Event', 
                            style: TextStyle(color: Colors.red),
                          ),
                          subtitle: const Text('This action cannot be undone',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () => _showDeleteEventDialog(),
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

  void _showEditEventNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Event Name'),
          content: TextField(
            controller: _eventTitleController,
            decoration: const InputDecoration(
              hintText: 'Enter new event name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Update event name in database
                setState(() {
                  // Update locally for now
                });
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event name updated successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showInviteLinkDialog() {
    final String inviteLink = 'https://weapp.com/events/${widget.eventId}';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invite Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Share this link to invite others:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        inviteLink,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: inviteLink));
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copied to clipboard')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteEventDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement event deletion
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
                Navigator.pop(context); // Return to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event deleted successfully')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.eventTitle, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showEventSettings,
          ),
          TextButton.icon(
            onPressed: _showManageMembers,
            icon: const Icon(Icons.people, color: Colors.deepPurple),
            label: const Text(
              'Members',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Event Photos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library, color: Colors.black),
                              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.black)),
                              onTap: () {
                                Navigator.pop(context);
                                _showTimeFrameDialog();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt, color: Colors.black),
                              title: const Text('Take a Photo', style: TextStyle(color: Colors.black)),
                              onTap: () {
                                Navigator.pop(context);
                                _takePhoto();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_photo_alternate, color: Colors.black),
                  label: const Text('Add Photos', style: TextStyle(color: Colors.black)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _images.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 64,
                          color: Colors.grey[800],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No photos yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button above to add photos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(_images[index]),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: () => _removeImage(index),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 