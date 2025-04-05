import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:we_app/screens/photo_review_screen.dart';
import 'dart:typed_data';

class PhotoAssignmentScreen extends StatefulWidget {
  final List<AssetEntity> selectedPhotos;
  final DateTime startDate;
  final DateTime endDate;
  final List<Map<String, dynamic>> members;

  const PhotoAssignmentScreen({
    super.key,
    required this.selectedPhotos,
    required this.startDate,
    required this.endDate,
    required this.members,
  });

  @override
  State<PhotoAssignmentScreen> createState() => _PhotoAssignmentScreenState();
}

class _PhotoAssignmentScreenState extends State<PhotoAssignmentScreen> with SingleTickerProviderStateMixin {
  final Map<String, List<AssetEntity>> _assignedPhotos = {};
  final Map<String, bool> _selectedPhotos = {};
  bool _isSelecting = false;
  String? _selectedMember;
  int _currentIndex = 0;
  final Set<String> _assignedPhotoIds = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize all photos as unselected
    for (final photo in widget.selectedPhotos) {
      _selectedPhotos[photo.id] = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _togglePhotoSelection(String photoId) {
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a member first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_assignedPhotoIds.contains(photoId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This photo is already assigned'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _selectedPhotos[photoId] = !(_selectedPhotos[photoId] ?? false);
    });
  }

  void _selectAllPhotos() {
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a member first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      for (final photo in widget.selectedPhotos) {
        if (!_assignedPhotoIds.contains(photo.id)) {
          _selectedPhotos[photo.id] = true;
        }
      }
    });
  }

  void _assignSelectedPhotos() {
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a member first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedPhotos = widget.selectedPhotos
        .where((photo) => _selectedPhotos[photo.id] ?? false)
        .toList();

    if (selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one photo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      if (_selectedMember == 'All Members') {
        // Assign to all members
        for (final member in widget.members) {
          _assignedPhotos[member['name']] = [
            ...(_assignedPhotos[member['name']] ?? []),
            ...selectedPhotos,
          ];
        }
      } else {
        _assignedPhotos[_selectedMember!] = [
          ...(_assignedPhotos[_selectedMember!] ?? []),
          ...selectedPhotos,
        ];
      }
      
      // Add to assigned photos set
      for (final photo in selectedPhotos) {
        _assignedPhotoIds.add(photo.id);
        _selectedPhotos[photo.id] = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedPhotos.length} photos assigned to ${_selectedMember}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Photos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Assign'),
            Tab(text: 'Review'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Assign Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedMember,
                  decoration: const InputDecoration(
                    labelText: 'Select Member',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'All Members',
                      child: Text('All Members'),
                    ),
                    ...widget.members.map((member) {
                      return DropdownMenuItem<String>(
                        value: member['name'],
                        child: Text(member['name']),
                      );
                    }).toList(),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMember = newValue;
                      // Clear selection when changing member
                      for (final photo in widget.selectedPhotos) {
                        _selectedPhotos[photo.id] = false;
                      }
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.selectedPhotos.length - _assignedPhotoIds.length} photos available',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _selectAllPhotos,
                      icon: const Icon(Icons.select_all),
                      label: const Text('Select All'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: widget.selectedPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = widget.selectedPhotos[index];
                    final isSelected = _selectedPhotos[photo.id] ?? false;
                    final isAssigned = _assignedPhotoIds.contains(photo.id);
                    
                    return GestureDetector(
                      onTap: isAssigned ? null : () => _togglePhotoSelection(photo.id),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FutureBuilder<Uint8List?>(
                            future: photo.thumbnailData,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              }
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                          if (isAssigned)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            )
                          else if (isSelected)
                            Container(
                              color: Colors.deepPurple.withOpacity(0.5),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton(
                  onPressed: _assignedPhotoIds.length == widget.selectedPhotos.length
                      ? () {
                          _tabController.animateTo(1);
                        }
                      : _assignSelectedPhotos,
                  child: Text(
                    _assignedPhotoIds.length == widget.selectedPhotos.length
                        ? 'Review Photos'
                        : 'Assign Selected Photos',
                  ),
                ),
              ),
            ],
          ),
          // Review Tab
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.members.length,
                  itemBuilder: (context, index) {
                    final member = widget.members[index];
                    final assignedPhotos = _assignedPhotos[member['name']] ?? [];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: Text(
                            member['avatar'].toString().substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(member['name']),
                        subtitle: Text('${assignedPhotos.length} photos assigned'),
                        trailing: assignedPhotos.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PhotoReviewScreen(
                                        selectedPhotos: assignedPhotos,
                                        startDate: widget.startDate,
                                        endDate: widget.endDate,
                                        members: widget.members,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoReviewScreen(
                          selectedPhotos: widget.selectedPhotos,
                          startDate: widget.startDate,
                          endDate: widget.endDate,
                          members: widget.members,
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Event Group'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 