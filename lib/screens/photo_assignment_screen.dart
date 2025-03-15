import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class PhotoAssignmentScreen extends StatefulWidget {
  final List<AssetEntity> selectedPhotos;
  final List<String> members;

  const PhotoAssignmentScreen({
    super.key,
    required this.selectedPhotos,
    required this.members,
  });

  @override
  State<PhotoAssignmentScreen> createState() => _PhotoAssignmentScreenState();
}

class _PhotoAssignmentScreenState extends State<PhotoAssignmentScreen> with SingleTickerProviderStateMixin {
  late List<AssetEntity> _photos;
  final Map<String, List<AssetEntity>> _memberPhotos = {};
  String? _selectedMember;
  final Set<String> _selectedPhotoIds = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.selectedPhotos);
    // Initialize member photos map
    for (var member in widget.members) {
      _memberPhotos[member] = [];
    }
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _togglePhotoSelection(AssetEntity photo) {
    setState(() {
      if (_selectedPhotoIds.contains(photo.id)) {
        _selectedPhotoIds.remove(photo.id);
      } else {
        _selectedPhotoIds.add(photo.id);
      }
    });
  }

  void _assignSelectedPhotos() {
    if (_selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a member first')),
      );
      return;
    }

    if (_selectedPhotoIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select photos to assign')),
      );
      return;
    }

    setState(() {
      if (_selectedMember == 'All Members') {
        // Assign selected photos to all members
        for (var member in widget.members) {
          _memberPhotos[member]!.addAll(
            _photos.where((photo) => _selectedPhotoIds.contains(photo.id))
          );
        }
      } else {
        // Assign selected photos to the selected member
        _memberPhotos[_selectedMember]!.addAll(
          _photos.where((photo) => _selectedPhotoIds.contains(photo.id))
        );
      }
      
      // Remove assigned photos from the unassigned list
      _photos.removeWhere((photo) => _selectedPhotoIds.contains(photo.id));
      _selectedPhotoIds.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photos assigned successfully'),
        backgroundColor: Colors.green,
      ),
    );

    // Switch to review tab
    _tabController.animateTo(1);
  }

  void _navigateToEventAlbum() {
    // Collect all assigned photos into a single list
    final List<AssetEntity> allAssignedPhotos = [];
    for (var photos in _memberPhotos.values) {
      allAssignedPhotos.addAll(photos);
    }
    
    // Remove duplicates if any
    final uniquePhotos = allAssignedPhotos.toSet().toList();
    
    // Navigate back with the assigned photos
    Navigator.pop(context, uniquePhotos);
  }

  Widget _buildAssignTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Member Selection Dropdown
              DropdownButtonFormField<String>(
                value: _selectedMember,
                decoration: InputDecoration(
                  labelText: 'Select Member',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'All Members',
                    child: Text('All Members'),
                  ),
                  ...widget.members.map((String member) {
                    return DropdownMenuItem<String>(
                      value: member,
                      child: Text(member),
                    );
                  }).toList(),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _selectedMember = value;
                  });
                },
              ),
            ],
          ),
        ),
        if (_photos.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Unassigned Photos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_selectedPhotoIds.length == _photos.length) {
                        _selectedPhotoIds.clear();
                      } else {
                        _selectedPhotoIds.addAll(_photos.map((p) => p.id));
                      }
                    });
                  },
                  icon: Icon(
                    _selectedPhotoIds.length == _photos.length
                        ? Icons.deselect
                        : Icons.select_all,
                  ),
                  label: Text(
                    _selectedPhotoIds.length == _photos.length
                        ? 'Deselect All'
                        : 'Select All',
                  ),
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
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                final isSelected = _selectedPhotoIds.contains(photo.id);
                return GestureDetector(
                  onTap: () => _togglePhotoSelection(photo),
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
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(red: 33, green: 150, blue: 243, alpha: 77),
                              border: Border.all(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ] else ...[
          const Expanded(
            child: Center(
              child: Text(
                'No photos left to assign',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewTab() {
    return ListView.builder(
      itemCount: widget.members.length,
      itemBuilder: (context, index) {
        final member = widget.members[index];
        final memberPhotos = _memberPhotos[member] ?? [];
        
        if (memberPhotos.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '$member (${memberPhotos.length} photos)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: memberPhotos.length,
                itemBuilder: (context, photoIndex) {
                  final photo = memberPhotos[photoIndex];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: FutureBuilder<Uint8List?>(
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
                    ),
                  );
                },
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Photos'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Assign'),
            Tab(text: 'Review'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAssignTab(),
          _buildReviewTab(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 26),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_tabController.index == 0 && _selectedPhotoIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _assignSelectedPhotos,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Assign ${_selectedPhotoIds.length} Selected Photos',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_photos.isEmpty) // Only show Event Album button when all photos are assigned
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            _navigateToEventAlbum();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Event Album',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 