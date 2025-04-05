import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/services.dart';
import 'photo_review_screen.dart';
import 'photo_assignment_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final File? eventPhoto;
  final String eventType;
  final List<Map<String, dynamic>> members;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    this.eventPhoto,
    required this.eventType,
    required this.members,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final List<AssetEntity> _images = []; // This will store AssetEntity objects
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
  File? _eventPhoto;

  @override
  void initState() {
    super.initState();
    _eventTitleController.text = widget.eventTitle;
    _eventPhoto = widget.eventPhoto;
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
                            color: Colors.deepPurple.withValues(red: 103, green: 58, blue: 183, alpha: 26),
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
                        const bool isCurrentUserAdmin = true; // TODO: Replace with actual user role check
                        final bool isMemberAdmin = member['role'] == 'Admin';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isMemberAdmin 
                                  ? Colors.deepPurple.withValues(red: 103, green: 58, blue: 183, alpha: 26)
                                  : Colors.grey.withValues(red: 158, green: 158, blue: 158, alpha: 26),
                              child: Text(
                                member['avatar'].toString().substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: isMemberAdmin ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
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
                                      ? Colors.deepPurple.withValues(red: 103, green: 58, blue: 183, alpha: 26)
                                      : Colors.grey.withValues(red: 158, green: 158, blue: 158, alpha: 26),
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
                    child: Text(
                      user['avatar'].toString().substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
      backgroundColor: const Color(0xFF1C1C1E),
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
                            color: Colors.white,
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[800],
                              suffixIcon: const Icon(Icons.calendar_today, color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
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
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[800],
                              suffixIcon: const Icon(Icons.access_time, color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
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
                        color: Colors.white,
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
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[800],
                              suffixIcon: const Icon(Icons.calendar_today, color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
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
                              labelStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[800],
                              suffixIcon: const Icon(Icons.access_time, color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
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
    final BuildContext contextRef = context;
    try {
      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: contextRef,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Request permission to access photos
      final PermissionState permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        if (!mounted) return;
        Navigator.pop(contextRef);
        ScaffoldMessenger.of(contextRef).showSnackBar(
          const SnackBar(
            content: Text('Permission to access photos was denied'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get all photos with pagination
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      
      if (albums.isEmpty) {
        if (!mounted) return;
        Navigator.pop(contextRef);
        ScaffoldMessenger.of(contextRef).showSnackBar(
          const SnackBar(
            content: Text('No photo albums found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Use the selected date/time values
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

      // Get photos in smaller batches and filter by date range
      const int batchSize = 100;
      List<AssetEntity> filteredPhotos = [];
      int start = 0;
      bool hasMorePhotos = true;

      while (hasMorePhotos && mounted) {
        final List<AssetEntity> batch = await albums.first.getAssetListRange(
          start: start,
          end: start + batchSize,
        );
        
        if (batch.isEmpty) {
          hasMorePhotos = false;
        } else {
          // Filter photos in the current batch
          filteredPhotos.addAll(batch.where((photo) {
            final DateTime photoDate = photo.createDateTime;
            return photoDate.isAfter(startDateTime) && 
                   photoDate.isBefore(endDateTime.add(const Duration(days: 1)));
          }));
          start += batchSize;
        }
      }

      if (filteredPhotos.isEmpty) {
        if (!mounted) return;
        Navigator.pop(contextRef);
        ScaffoldMessenger.of(contextRef).showSnackBar(
          const SnackBar(
            content: Text('No photos found in the selected date range'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!mounted) return;
      Navigator.pop(contextRef);

      // Show the review screen
      final List<AssetEntity>? selectedPhotos = await Navigator.push(
        contextRef,
        MaterialPageRoute(
          builder: (context) => PhotoReviewScreen(
            selectedPhotos: filteredPhotos,
            startDate: startDateTime,
            endDate: endDateTime,
            members: _members,
          ),
        ),
      );

      if (selectedPhotos != null && mounted) {
        setState(() {
          _images.addAll(selectedPhotos);
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(contextRef);
        ScaffoldMessenger.of(contextRef).showSnackBar(
          SnackBar(
            content: Text('Error selecting photos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    final BuildContext contextRef = context;
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null && mounted) {
        // Convert XFile to AssetEntity
        final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
          type: RequestType.image,
        );
        if (albums.isNotEmpty) {
          final List<AssetEntity> recentPhotos = await albums.first.getAssetListRange(
            start: 0,
            end: 1,
          );
          if (recentPhotos.isNotEmpty) {
            setState(() {
              _images.add(recentPhotos.first);
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(contextRef).showSnackBar(
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

  Future<void> _showInviteLinkDialog() async {
    final BuildContext contextRef = context;
    final String inviteLink = 'https://weapp.com/events/${widget.eventId}';
    if (!mounted) return;
    
    showDialog(
      context: contextRef,
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

  void _navigateToPhotoAssignment(List<AssetEntity> selectedPhotos) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoAssignmentScreen(
          selectedPhotos: selectedPhotos,
          startDate: _startDate!,
          endDate: _endDate!,
          members: _members,
        ),
      ),
    ).then((assignedPhotos) {
      if (assignedPhotos != null) {
        // Handle the assigned photos
        setState(() {
          _images.addAll(assignedPhotos);
        });
      }
    });
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
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Invite Members',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.eventTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.photo_library, color: Colors.grey[800], size: 20),
                                const SizedBox(width: 4),
                                Text('${_images.length}', style: TextStyle(color: Colors.grey[800])),
                                const SizedBox(width: 16),
                                Icon(Icons.people, color: Colors.grey[800], size: 20),
                                const SizedBox(width: 4),
                                Text('${_members.length}', style: TextStyle(color: Colors.grey[800])),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Implement share link functionality
                          Clipboard.setData(ClipboardData(text: 'join.photocircleapp.com/389C0R9C9K'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Join link copied to clipboard')),
                          );
                        },
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: const Text(
                          'Share Join Link',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'join.photocircleapp.com/389C0R9C9K',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.grey),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: 'join.photocircleapp.com/389C0R9C9K'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Join link copied to clipboard')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'OTHER OPTIONS',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.people_outline, color: Colors.grey[800]),
                              title: Text(
                                'Invite Existing Users',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              subtitle: Text(
                                'Select users from your circles',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onTap: () {
                                // Implement invite existing users
                              },
                            ),
                            Divider(height: 1, color: Colors.grey[300]),
                            ListTile(
                              leading: Icon(Icons.qr_code, color: Colors.grey[800]),
                              title: Text(
                                'Show QR Code',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              subtitle: Text(
                                'Print a code that others can scan',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onTap: () {
                                // Implement QR code functionality
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.person_add, color: Colors.deepPurple),
            label: const Text(
              'Invite',
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
      floatingActionButton: FloatingActionButton(
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
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add_photo_alternate, color: Colors.white),
      ),
      body: Column(
        children: [
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
                          'Tap the + button to add photos',
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
                      final photo = _images[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            FutureBuilder<Uint8List?>(
                              future: photo.thumbnailData,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
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