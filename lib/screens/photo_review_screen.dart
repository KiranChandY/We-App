import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';
import 'photo_assignment_screen.dart';

class PhotoReviewScreen extends StatefulWidget {
  final List<AssetEntity> selectedPhotos;
  final DateTime startDate;
  final DateTime endDate;
  final List<Map<String, dynamic>> members;

  const PhotoReviewScreen({
    super.key,
    required this.selectedPhotos,
    required this.startDate,
    required this.endDate,
    required this.members,
  });

  @override
  State<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends State<PhotoReviewScreen> {
  final List<AssetEntity> _selectedPhotos = [];
  bool _isLoading = true;
  bool _isSelecting = false;
  Offset? _selectionStart;
  Offset? _selectionEnd;
  final Map<int, bool> _selectionMap = {};

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    // Pre-select all photos
    _selectedPhotos.addAll(widget.selectedPhotos);
    for (int i = 0; i < widget.selectedPhotos.length; i++) {
      _selectionMap[i] = true;
    }
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    for (var photo in widget.selectedPhotos) {
      await photo.originBytes;
    }
    setState(() => _isLoading = false);
  }

  void _togglePhotoSelection(AssetEntity photo) {
    setState(() {
      if (_selectedPhotos.contains(photo)) {
        _selectedPhotos.remove(photo);
        _selectionMap[widget.selectedPhotos.indexOf(photo)] = false;
      } else {
        _selectedPhotos.add(photo);
        _selectionMap[widget.selectedPhotos.indexOf(photo)] = true;
      }
    });
  }

  void _toggleMultiSelect(bool start) {
    setState(() {
      _isSelecting = start;
      if (!start) {
        _selectionStart = null;
        _selectionEnd = null;
      }
    });
  }

  void _updateSelection(Offset position) {
    setState(() {
      _selectionEnd = position;
      _updateSelectedPhotos();
    });
  }

  void _updateSelectedPhotos() {
    if (_selectionStart == null || _selectionEnd == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final gridWidth = size.width;
    final gridHeight = size.height;

    final startX = _selectionStart!.dx;
    final startY = _selectionStart!.dy;
    final endX = _selectionEnd!.dx;
    final endY = _selectionEnd!.dy;

    final left = startX < endX ? startX : endX;
    final right = startX > endX ? startX : endX;
    final top = startY < endY ? startY : endY;
    final bottom = startY > endY ? startY : endY;

    for (int i = 0; i < widget.selectedPhotos.length; i++) {
      final row = i ~/ 3;
      final col = i % 3;
      final itemWidth = gridWidth / 3;
      final itemHeight = gridHeight / (widget.selectedPhotos.length / 3).ceil();

      final itemLeft = col * itemWidth;
      final itemTop = row * itemHeight;
      final itemRight = itemLeft + itemWidth;
      final itemBottom = itemTop + itemHeight;

      if (itemRight > left && itemLeft < right && itemBottom > top && itemTop < bottom) {
        _selectionMap[i] = true;
        if (!_selectedPhotos.contains(widget.selectedPhotos[i])) {
          _selectedPhotos.add(widget.selectedPhotos[i]);
        }
      }
    }
  }

  String _formatDateRange() {
    final start = widget.startDate;
    final end = widget.endDate;
    return '${start.day} ${_getMonthName(start.month)} ${start.year} - ${end.day} ${_getMonthName(end.month)} ${end.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Review Photos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateRange(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_selectedPhotos.length} of ${widget.selectedPhotos.length} photos selected',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Photo Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onPanStart: (details) {
                      _selectionStart = details.localPosition;
                      _toggleMultiSelect(true);
                    },
                    onPanUpdate: (details) {
                      _updateSelection(details.localPosition);
                    },
                    onPanEnd: (details) {
                      _toggleMultiSelect(false);
                    },
                    child: Stack(
                      children: [
                        GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: widget.selectedPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = widget.selectedPhotos[index];
                            final isSelected = _selectedPhotos.contains(photo);
                            return GestureDetector(
                              onTap: () => _togglePhotoSelection(photo),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: FutureBuilder<Uint8List?>(
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
                                  ),
                                  if (isSelected)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        if (_isSelecting && _selectionStart != null && _selectionEnd != null)
                          Positioned(
                            left: _selectionStart!.dx < _selectionEnd!.dx ? _selectionStart!.dx : _selectionEnd!.dx,
                            top: _selectionStart!.dy < _selectionEnd!.dy ? _selectionStart!.dy : _selectionEnd!.dy,
                            child: Container(
                              width: (_selectionEnd!.dx - _selectionStart!.dx).abs(),
                              height: (_selectionEnd!.dy - _selectionStart!.dy).abs(),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.deepPurple,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          // Bottom Action Bar
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedPhotos.length} photos selected',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: FilledButton.icon(
                    onPressed: _selectedPhotos.isNotEmpty
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhotoAssignmentScreen(
                                  selectedPhotos: _selectedPhotos,
                                  startDate: widget.startDate,
                                  endDate: widget.endDate,
                                  members: widget.members,
                                ),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.people),
                    label: const Text('Assign Photos'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 