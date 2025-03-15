import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _allowNotifications = true;
  bool _newEvents = true;
  bool _eventUpdates = true;
  bool _memberJoined = true;
  bool _photoUploads = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Push Notifications',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Allow Notifications'),
                    subtitle: const Text('Enable or disable all notifications'),
                    value: _allowNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        _allowNotifications = value;
                        if (!value) {
                          // Disable all other notifications when main toggle is off
                          _newEvents = false;
                          _eventUpdates = false;
                          _memberJoined = false;
                          _photoUploads = false;
                        }
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('New Events'),
                    subtitle: const Text('Get notified when new events are created'),
                    value: _allowNotifications && _newEvents,
                    onChanged: _allowNotifications
                        ? (bool value) {
                            setState(() => _newEvents = value);
                          }
                        : null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Event Updates'),
                    subtitle: const Text('Get notified about changes to events'),
                    value: _allowNotifications && _eventUpdates,
                    onChanged: _allowNotifications
                        ? (bool value) {
                            setState(() => _eventUpdates = value);
                          }
                        : null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Member Joined'),
                    subtitle: const Text('Get notified when new members join events'),
                    value: _allowNotifications && _memberJoined,
                    onChanged: _allowNotifications
                        ? (bool value) {
                            setState(() => _memberJoined = value);
                          }
                        : null,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Photo Uploads'),
                    subtitle: const Text('Get notified when new photos are added'),
                    value: _allowNotifications && _photoUploads,
                    onChanged: _allowNotifications
                        ? (bool value) {
                            setState(() => _photoUploads = value);
                          }
                        : null,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'When notifications are enabled, you\'ll receive updates about events, members, and photos.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 