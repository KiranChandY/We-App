import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'event_members_screen.dart';
import 'event_details_screen.dart';
import 'all_members_screen.dart';
import 'create_event_screen.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Sample events data with event types
  final List<Map<String, dynamic>> _events = [
    {
      'id': 'event_1',
      'title': 'Summer Trip',
      'type': 'Trip',
      'date': DateTime.now().add(const Duration(days: 1)),
      'description': 'A fun summer trip to the beach with friends.',
      'image': 'https://picsum.photos/200/300?random=1',
    },
    {
      'id': 'event_2',
      'title': 'John\'s Birthday',
      'type': 'Birthday',
      'date': DateTime.now().add(const Duration(days: 2)),
      'description': 'Celebrating John\'s birthday with family and friends.',
      'image': 'https://picsum.photos/200/300?random=2',
    },
    {
      'id': 'event_3',
      'title': 'Sarah & Mike Wedding',
      'type': 'Wedding',
      'date': DateTime.now().add(const Duration(days: 3)),
      'description': 'Join us in celebrating Sarah and Mike\'s special day.',
      'image': 'https://picsum.photos/200/300?random=3',
    },
    {
      'id': 'event_4',
      'title': 'Emma\'s Graduation',
      'type': 'Graduation',
      'date': DateTime.now().add(const Duration(days: 4)),
      'location': 'University Hall',
      'description': 'Celebrating Emma\'s graduation from university.',
      'image': 'https://picsum.photos/200/300?random=4',
    },
    {
      'id': 'event_5',
      'title': 'Anniversary Party',
      'type': 'Anniversary',
      'date': DateTime.now().add(const Duration(days: 5)),
      'location': 'Restaurant',
      'description': 'Celebrating 10 years of togetherness.',
      'image': 'https://picsum.photos/200/300?random=5',
    },
    {
      'id': 'event_6',
      'title': 'Kids Playdate',
      'type': 'Group for Your Child',
      'date': DateTime.now().add(const Duration(days: 6)),
      'location': 'Park',
      'description': 'Fun playdate for kids at the local park.',
      'image': 'https://picsum.photos/200/300?random=6',
    },
    {
      'id': 'event_7',
      'title': 'Team Building',
      'type': 'Custom',
      'date': DateTime.now().add(const Duration(days: 7)),
      'location': 'Office',
      'description': 'Team building activities for the department.',
      'image': 'https://picsum.photos/200/300?random=7',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredEvents {
    if (_searchQuery.isEmpty) {
      return _events;
    }
    return _events.where((event) {
      final title = event['title'].toString().toLowerCase();
      final location = event['location'].toString().toLowerCase();
      final description = event['description'].toString().toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      
      return title.contains(searchLower) ||
             location.contains(searchLower) ||
             description.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildEventsTab(),
          AllMembersScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
        backgroundColor: AppTheme.surfaceColor,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Members',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeTag(String type) {
    if (type == 'Custom') return const SizedBox.shrink();

    Color tagColor;
    switch (type) {
      case 'Trip':
        tagColor = Colors.blue;
        break;
      case 'Group for Your Child':
        tagColor = Colors.pink;
        break;
      case 'Wedding':
        tagColor = Colors.red;
        break;
      case 'Birthday':
        tagColor = Colors.orange;
        break;
      case 'Anniversary':
        tagColor = Colors.purple;
        break;
      case 'Graduation':
        tagColor = Colors.green;
        break;
      default:
        tagColor = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: tagColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: tagColor,
        ),
      ),
    );
  }

  Widget _buildEventsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Events',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const CreateEventScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Event'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredEvents.length,
              itemBuilder: (context, index) {
                final event = _filteredEvents[index];
                return _buildEventCard(event);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _navigateToEventDetails(event);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Event Photo in Circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
                child: ClipOval(
                  child: Image.network(
                    event['image'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildEventTypeTag(event['type']),
                        const Spacer(),
                        Text(
                          DateFormat('dd MMMM yyyy').format(event['date']),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEventDetails(Map<String, dynamic> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(
          eventId: event['id'],
          eventTitle: event['title'],
          eventType: event['type'],
          members: (event['members'] as List<String>? ?? []).map((member) => {
            'id': member,
            'name': member,
            'avatar': member[0].toUpperCase(),
          }).toList(),
        ),
      ),
    );
  }
} 